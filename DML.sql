-- fokus utama atau contoh case pada penerimaan jalur zonasi


DECLARE
    -- Variabel Bantuan Master
    v_npsn_smp VARCHAR2(20);
    v_npsn_sma VARCHAR2(20);
    v_nisn VARCHAR2(20);
    v_username VARCHAR2(100);
    
    -- Variabel Bantuan Simulasi Bug Zonasi
    v_deleted_at TIMESTAMP;
    v_action_verif VARCHAR2(50);
    v_update_verif TIMESTAMP;
BEGIN

    -- 1. MASTER DATA (Dinaikkan menjadi 50 Baris)
    FOR i IN 1..50 LOOP
        -- Roles & Office Users
        INSERT INTO roles (id, name) 
        VALUES (i, 'Role Panitia ' || i);
        
        v_username := 'admin_' || i;
        INSERT INTO office_users (id, name, username, password, role_id) 
        VALUES (i, 'Operator ' || i, v_username, 'pass123', i);
        
        -- Junior Schools
        v_npsn_smp := '2020' || LPAD(i, 4, '0');
        INSERT INTO junior_schools (id, npsn, name) 
        VALUES (i, v_npsn_smp, 'SMP Negeri ' || i || ' Makassar');
        
        -- Schools 
        v_npsn_sma := '1010' || LPAD(i, 4, '0');
        INSERT INTO schools (id, name, npsn, pagu_zonasi, city_id) 
        VALUES (
            i, 
            CASE WHEN i = 1 THEN 'SMA Negeri 1 Makassar' ELSE 'SMA Dummy ' || i END, 
            v_npsn_sma, 
            CASE WHEN i = 1 THEN 130 ELSE 50 END, 
            1
        );
        
        -- School Users
        INSERT INTO school_users (id, office_user_username, school_npsn) 
        VALUES (i, v_username, v_npsn_sma);
    END LOOP;

    -- 2. SIMULASI BUG ZONASI (Tepat 130 Siswa Sesuai Pagu SMAN 1 Makassar)
    FOR i IN 1..130 LOOP
        v_nisn := '99' || LPAD(i, 8, '0');
        
        -- A. LOGIKA SOFT-DELETE (Siswa ID 101-115 terhapus pada 24 Juni)
        IF i BETWEEN 101 AND 115 THEN
            v_deleted_at := TO_TIMESTAMP('2023-06-24 08:30:00', 'YYYY-MM-DD HH24:MI:SS');
        ELSE
            v_deleted_at := NULL;
        END IF;

        -- Insert Users
        INSERT INTO users (id, nisn, name, gender, school_destination_id, deleted_at) 
        VALUES (i, v_nisn, 'Siswa Zonasi ' || i, CASE WHEN MOD(i,2)=0 THEN 'P' ELSE 'L' END, 1, v_deleted_at);

        -- Insert Registrations (Semua mendaftar pada 21 Juni)
        INSERT INTO registrations_zonasi (id, user_id, school_destination_id, status, created_at) 
        VALUES (i, i, 1, 'terverifikasi', TO_TIMESTAMP('2023-06-21 10:00:00', 'YYYY-MM-DD HH24:MI:SS'));

        -- B. LOGIKA MISMATCH VERIFIKASI (Siswa ID 116-130 dibatalkan pada 24 Juni)
        IF i BETWEEN 116 AND 130 THEN
            v_action_verif := 'Batal';
            v_update_verif := TO_TIMESTAMP('2023-06-24 09:00:00', 'YYYY-MM-DD HH24:MI:SS');
            
            -- Insert Audit Log khusus yang dibatalkan
            INSERT INTO audit_verifikasi_ppdb (id, verification_id, old_action, new_action, operator_id, log_date)
            VALUES (i, i, 'Lulus', 'Batal', 1, v_update_verif);
        ELSE
            v_action_verif := 'Lulus';
            v_update_verif := TO_TIMESTAMP('2023-06-23 09:00:00', 'YYYY-MM-DD HH24:MI:SS');
        END IF;

        -- Insert Verifikasi
        INSERT INTO verification_zonasi (id, registration_id, operator_id, action, created_at, updated_at) 
        VALUES (i, i, 1, v_action_verif, TO_TIMESTAMP('2023-06-23 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), v_update_verif);

        -- C. PENERIMAAN ZONASI (Semua 130 Siswa masuk di 23 Juni)
        INSERT INTO penerimaan_zonasi (id, verification_id, code, created_at) 
        VALUES (i, i, 'ZON-23-' || LPAD(i, 4, '0'), TO_TIMESTAMP('2023-06-23 15:00:00', 'YYYY-MM-DD HH24:MI:SS'));

    END LOOP;

    -- 3. JALUR LAINNYA 
    FOR i IN 1..50 LOOP
        -- Registrasi
        INSERT INTO registrations_afirmasi (id, user_id, school_destination_id, status) VALUES (i, i, i, 'pending');
        INSERT INTO registrations_mutasi (id, user_id, school_destination_id, status) VALUES (i, i, i, 'pending');
        INSERT INTO registrations_prestasi_mandiri (id, user_id, school_destination_id, status) VALUES (i, i, i, 'pending');
        
        -- Verifikasi
        INSERT INTO verification_afirmasi (id, registration_id, operator_id, action) VALUES (i, i, 1, 'Lulus');
        INSERT INTO verification_mutasi (id, registration_id, operator_id, action) VALUES (i, i, 1, 'Lulus');
        INSERT INTO verification_prestasi_mandiri (id, registration_id, operator_id, action) VALUES (i, i, 1, 'Lulus');
        
        -- Penerimaan
        INSERT INTO penerimaan_afirmasi (id, verification_id, code) VALUES (i, i, 'AFI-' || LPAD(i, 4, '0'));
        INSERT INTO penerimaan_mutasi (id, verification_id, code) VALUES (i, i, 'MUT-' || LPAD(i, 4, '0'));
        INSERT INTO penerimaan_prestasi_mandiri (id, verification_id, code) VALUES (i, i, 'PRE-' || LPAD(i, 4, '0'));
    END LOOP;

    COMMIT;
END;
/
-- lihat seluruh siswa yang diterima zonasi:
SELECT * FROM penerimaan_zonasi;

-- BUG 1
-- 1). Lihat SEMUA siswa (termasuk yang soft-deleted)
SELECT id, nisn, name, deleted_at
FROM users
ORDER BY id;

-- 2). Lihat siswa yang AKTIF saja (belum dihapus)
SELECT id, nisn, name, deleted_at
FROM users
WHERE deleted_at IS NULL
ORDER BY id;

-- 3). Lihat siswa yang SOFT-DELETED saja (ID 101-115)
SELECT id, nisn, name, deleted_at
FROM users
WHERE deleted_at IS NOT NULL
ORDER BY id;

-- Bug 2: Mismatch - sudah diterima tapi verifikasi Batal (ID 116-130)
SELECT u.id, u.name, v.action, p.code AS kode_penerimaan
FROM users u
JOIN verification_zonasi v ON v.id = u.id
JOIN penerimaan_zonasi p ON p.verification_id = v.id
WHERE v.action = 'Batal';


-- BUG 3: SIMULASI QUERY
-- Simulasi "versi cache" (snapshot 23 Juni, sebelum dynamic ranking)
SELECT u.name, p.code, 'LULUS (Cache 23 Jun)' AS status
FROM penerimaan_zonasi p
JOIN verification_zonasi v ON v.id = p.verification_id
JOIN registrations_zonasi r ON r.id = v.registration_id
JOIN users u ON u.id = r.user_id
WHERE r.school_destination_id = 1
AND p.created_at <= TO_TIMESTAMP('2023-06-23 23:59:59', 'YYYY-MM-DD HH24:MI:SS');


-- Simulasi "versi DB utama" (setelah dynamic ranking 24 Juni)
SELECT u.name, p.code, 'LULUS (DB Utama)' AS status
FROM penerimaan_zonasi p
JOIN verification_zonasi v ON v.id = p.verification_id
JOIN registrations_zonasi r ON r.id = v.registration_id
JOIN users u ON u.id = r.user_id
WHERE r.school_destination_id = 1
AND v.action = 'Lulus'
AND u.deleted_at IS NULL;
