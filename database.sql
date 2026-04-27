-- SQL: ORACLE


-- DDL Sistem PPDB 


-- TABEL: roles
CREATE TABLE roles (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR2(100) NOT NULL,
    created_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at  TIMESTAMP DEFAULT SYSTIMESTAMP
);


-- TABEL: junior_schools 
CREATE TABLE junior_schools (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    npsn        VARCHAR2(20)  UNIQUE NOT NULL,
    name        VARCHAR2(255) NOT NULL,
    created_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at  TIMESTAMP DEFAULT SYSTIMESTAMP
);


-- TABEL: schools (Data Sekolah Tujuan)
CREATE TABLE schools (
    id                              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name                            VARCHAR2(255)  NOT NULL,
    kode                            VARCHAR2(50),
    npsn                            VARCHAR2(20)   UNIQUE NOT NULL,
    minimum_average                 NUMBER(5,2),
    city_id                         NUMBER,
    latitude                        NUMBER(11,8),
    longitude                       NUMBER(11,8),
    pagu_afirmasi                   NUMBER(5) DEFAULT 0,
    pagu_mutasi                     NUMBER(5) DEFAULT 0,
    pagu_prestasi_undangan          NUMBER(5) DEFAULT 0,
    pagu_zonasi                     NUMBER(5) DEFAULT 0,
    pagu_prestasi_tesmandiri        NUMBER(5) DEFAULT 0,
    pagu_tidak_naik_kelas           NUMBER(5) DEFAULT 0,
    school_code                     VARCHAR2(50),
    kebijakan_sisa_pagu_afirmasi    VARCHAR2(255),
    kebijakan_sisa_pagu_mutasi      VARCHAR2(255),
    kebijakan_sisa_pagu_undangan    VARCHAR2(255),
    kebijakan_sisa_pagu_zonasi      VARCHAR2(255),
    created_at                      TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at                      TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- TABEL: users (Data Calon Pendaftar)
CREATE TABLE users (
    id                      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    npsn                    VARCHAR2(20),
    nisn                    VARCHAR2(20)   UNIQUE NOT NULL,
    birth_date              DATE,
    name                    VARCHAR2(255)  NOT NULL,
    gender                  CHAR(1)        CHECK (gender IN ('L', 'P')),
    address                 CLOB,
    phone                   VARCHAR2(20),
    school_name             VARCHAR2(255),
    klaster                 VARCHAR2(100),  
    school_destination_id   NUMBER,
    latitude                NUMBER(11,8),
    longitude               NUMBER(11,8),
    registration_1_type     VARCHAR2(50),
    registration_2_type     VARCHAR2(50),
    registration_3_type     VARCHAR2(50),
    registration_1_id       NUMBER,
    registration_2_id       NUMBER,
    registration_3_id       NUMBER,
    acceptance_type         VARCHAR2(50),
    acceptance_id           NUMBER,
    jalur_prestasi          VARCHAR2(100),
    created_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    deleted_at              TIMESTAMP,
    CONSTRAINT fk_users_school FOREIGN KEY (school_destination_id) REFERENCES schools(id)
);


-- TABEL: office_users (Operator Kantor / Administrator)
CREATE TABLE office_users (
    id          NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name        VARCHAR2(255)  NOT NULL,
    username    VARCHAR2(100)  UNIQUE NOT NULL,
    password    VARCHAR2(255)  NOT NULL,
    role_id     NUMBER         NOT NULL,
    created_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at  TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_office_users_role FOREIGN KEY (role_id) REFERENCES roles(id)
);


-- TABEL: school_users (Operator Sekolah / Kepala Sekolah)
CREATE TABLE school_users (
    id                   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    office_user_username VARCHAR2(100) NOT NULL,
    school_npsn          VARCHAR2(20)  NOT NULL,
    CONSTRAINT fk_school_users_office FOREIGN KEY (office_user_username) REFERENCES office_users(username),
    CONSTRAINT fk_school_users_school FOREIGN KEY (school_npsn)          REFERENCES schools(npsn)
);


-- TABEL: registrations_afirmasi
CREATE TABLE registrations_afirmasi (
    id                      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                 NUMBER         NOT NULL,
    jenis                   VARCHAR2(100),
    school_destination_id   NUMBER         NOT NULL,
    distance                NUMBER(10,2),
    verification_schedule   TIMESTAMP,
    status                  VARCHAR2(50)   DEFAULT 'pending',
    documents               CLOB,
    created_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_reg_afirmasi_user   FOREIGN KEY (user_id)               REFERENCES users(id),
    CONSTRAINT fk_reg_afirmasi_school FOREIGN KEY (school_destination_id) REFERENCES schools(id)
);


-- TABEL: registrations_mutasi
CREATE TABLE registrations_mutasi (
    id                      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                 NUMBER         NOT NULL,
    jenis                   VARCHAR2(100),
    school_destination_id   NUMBER         NOT NULL,
    distance                NUMBER(10,2),
    verification_schedule   TIMESTAMP,
    status                  VARCHAR2(50)   DEFAULT 'pending',
    documents               CLOB,
    created_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_reg_mutasi_user   FOREIGN KEY (user_id)               REFERENCES users(id),
    CONSTRAINT fk_reg_mutasi_school FOREIGN KEY (school_destination_id) REFERENCES schools(id)
);


-- TABEL: registrations_prestasi_mandiri
CREATE TABLE registrations_prestasi_mandiri (
    id                      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                 NUMBER         NOT NULL,
    data                    CLOB,
    school_destination_id   NUMBER         NOT NULL,
    distance                NUMBER(10,2),
    verification_schedule   TIMESTAMP,
    status                  VARCHAR2(50)   DEFAULT 'pending',
    documents               CLOB,
    test_number             VARCHAR2(50),
    final_score             NUMBER(6,2),
    test_score              NUMBER(6,2),
    jurusan                 VARCHAR2(100),
    ruang_tes               VARCHAR2(100),
    created_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_reg_prestasi_user   FOREIGN KEY (user_id)               REFERENCES users(id),
    CONSTRAINT fk_reg_prestasi_school FOREIGN KEY (school_destination_id) REFERENCES schools(id)
);

-- TABEL: registrations_zonasi
CREATE TABLE registrations_zonasi (
    id                      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id                 NUMBER         NOT NULL,
    school_destination_id   NUMBER         NOT NULL,
    distance                NUMBER(10,2),
    verification_schedule   TIMESTAMP,
    status                  VARCHAR2(50)   DEFAULT 'pending',
    documents               CLOB,
    kk_date                 DATE,
    created_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at              TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_reg_zonasi_user   FOREIGN KEY (user_id)               REFERENCES users(id),
    CONSTRAINT fk_reg_zonasi_school FOREIGN KEY (school_destination_id) REFERENCES schools(id)
);


-- TABEL: verification_afirmasi
CREATE TABLE verification_afirmasi (
    id              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_id NUMBER         NOT NULL,
    operator_id     NUMBER         NOT NULL,
    action          VARCHAR2(50),
    alasan_batal    CLOB,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_verif_afirmasi_reg  FOREIGN KEY (registration_id) REFERENCES registrations_afirmasi(id),
    CONSTRAINT fk_verif_afirmasi_oper FOREIGN KEY (operator_id)      REFERENCES office_users(id)
);


-- TABEL: verification_mutasi
CREATE TABLE verification_mutasi (
    id              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_id NUMBER         NOT NULL,
    operator_id     NUMBER         NOT NULL,
    action          VARCHAR2(50),
    alasan_batal    CLOB,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_verif_mutasi_reg  FOREIGN KEY (registration_id) REFERENCES registrations_mutasi(id),
    CONSTRAINT fk_verif_mutasi_oper FOREIGN KEY (operator_id)      REFERENCES office_users(id)
);


-- TABEL: verification_prestasi_mandiri
CREATE TABLE verification_prestasi_mandiri (
    id              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_id NUMBER         NOT NULL,
    operator_id     NUMBER         NOT NULL,
    action          VARCHAR2(50),
    alasan_batal    CLOB,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_verif_prestasi_reg  FOREIGN KEY (registration_id) REFERENCES registrations_prestasi_mandiri(id),
    CONSTRAINT fk_verif_prestasi_oper FOREIGN KEY (operator_id)      REFERENCES office_users(id)
);


-- TABEL: verification_zonasi
CREATE TABLE verification_zonasi (
    id              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    registration_id NUMBER         NOT NULL,
    operator_id     NUMBER         NOT NULL,
    action          VARCHAR2(50),
    alasan_batal    CLOB,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_verif_zonasi_reg  FOREIGN KEY (registration_id) REFERENCES registrations_zonasi(id),
    CONSTRAINT fk_verif_zonasi_oper FOREIGN KEY (operator_id)      REFERENCES office_users(id)
);


-- TABEL: penerimaan_afirmasi
CREATE TABLE penerimaan_afirmasi (
    id              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    verification_id NUMBER         NOT NULL,
    kepsek_id       NUMBER,
    code            VARCHAR2(100)  UNIQUE,
    seen_at         TIMESTAMP,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_pen_afirmasi_verif  FOREIGN KEY (verification_id) REFERENCES verification_afirmasi(id),
    CONSTRAINT fk_pen_afirmasi_kepsek FOREIGN KEY (kepsek_id)        REFERENCES office_users(id)
);


-- TABEL: penerimaan_mutasi
CREATE TABLE penerimaan_mutasi (
    id              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    verification_id NUMBER         NOT NULL,
    code            VARCHAR2(100)  UNIQUE,
    seen_at         TIMESTAMP,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_pen_mutasi_verif FOREIGN KEY (verification_id) REFERENCES verification_mutasi(id)
);


-- TABEL: penerimaan_prestasi_mandiri
CREATE TABLE penerimaan_prestasi_mandiri (
    id              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    npsn            VARCHAR2(20),
    verification_id NUMBER         NOT NULL,
    code            VARCHAR2(100)  UNIQUE,
    seen_at         TIMESTAMP,
    CONSTRAINT fk_pen_prestasi_verif FOREIGN KEY (verification_id) REFERENCES verification_prestasi_mandiri(id)
);


-- TABEL: penerimaan_zonasi
CREATE TABLE penerimaan_zonasi (
    id              NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    verification_id NUMBER         NOT NULL,
    code            VARCHAR2(100)  UNIQUE,
    seen_at         TIMESTAMP,
    created_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at      TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_pen_zonasi_verif FOREIGN KEY (verification_id) REFERENCES verification_zonasi(id)
);

CREATE TABLE audit_verifikasi_ppdb (
    id              NUMBER PRIMARY KEY,
    verification_id NUMBER NOT NULL,
    old_action      VARCHAR2(50),
    new_action      VARCHAR2(50),
    operator_id     NUMBER,
    log_date        TIMESTAMP DEFAULT SYSTIMESTAMP
);



CREATE INDEX idx_users_school_dest      ON users(school_destination_id);
CREATE INDEX idx_users_deleted_at       ON users(deleted_at);

CREATE INDEX idx_reg_afirmasi_user      ON registrations_afirmasi(user_id);
CREATE INDEX idx_reg_afirmasi_school    ON registrations_afirmasi(school_destination_id);
CREATE INDEX idx_reg_afirmasi_status    ON registrations_afirmasi(status);

CREATE INDEX idx_reg_mutasi_user        ON registrations_mutasi(user_id);
CREATE INDEX idx_reg_mutasi_school      ON registrations_mutasi(school_destination_id);
CREATE INDEX idx_reg_mutasi_status      ON registrations_mutasi(status);

CREATE INDEX idx_reg_prestasi_user      ON registrations_prestasi_mandiri(user_id);
CREATE INDEX idx_reg_prestasi_school    ON registrations_prestasi_mandiri(school_destination_id);
CREATE INDEX idx_reg_prestasi_status    ON registrations_prestasi_mandiri(status);

CREATE INDEX idx_reg_zonasi_user        ON registrations_zonasi(user_id);
CREATE INDEX idx_reg_zonasi_school      ON registrations_zonasi(school_destination_id);
CREATE INDEX idx_reg_zonasi_status      ON registrations_zonasi(status);

CREATE INDEX idx_verif_afirmasi_reg     ON verification_afirmasi(registration_id);
CREATE INDEX idx_verif_mutasi_reg       ON verification_mutasi(registration_id);
CREATE INDEX idx_verif_prestasi_reg     ON verification_prestasi_mandiri(registration_id);
CREATE INDEX idx_verif_zonasi_reg       ON verification_zonasi(registration_id);

