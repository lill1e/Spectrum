CREATE TABLE users(
    id VARCHAR(30) NOT NULL PRIMARY KEY,
    clean_money INTEGER NOT NULL DEFAULT 0,
    dirty_money INTEGER NOT NULL DEFAULT 0,
    bank INTEGER NOT NULL DEFAULT 0,
    attributes TEXT[] NOT NULL DEFAULT ARRAY[]::text[],
    staff SMALLINT NOT NULL DEFAULT 0,
    PED VARCHAR(255) NOT NULL DEFAULT 'mp_m_freemode_01'::character varying,
    position JSONB NOT NULL DEFAULT '{"x": -269.4, "y": -955.3, "z": 31.2, "heading": 205.8}'::jsonb,
    inventory JSONB NOT NULL DEFAULT '{}'::jsonb,
    jobs JSONB NOT NULL DEFAULT '{}'::jsonb,
    skin JSONB,
    ammo JSONB NOT NULL DEFAULT '{"AMMO_MG": 0, "AMMO_SMG": 0, "AMMO_RIFLE": 0, "AMMO_PISTOL": 0, "AMMO_SNIPER": 0, "AMMO_SHOTGUN": 0}'::jsonb,
    dead BOOLEAN NOT NULL DEFAULT false,
    health INTEGER NOT NULL,
    armor INTEGER NOT NULL DEFAULT 0,
    licenses TEXT[] NOT NULL DEFAULT ARRAY[]::text[],
    property INTEGER,
    "group" INTEGER
);

CREATE TABLE vehicles(
    id VARCHAR(8) NOT NULL PRIMARY KEY,
    owner VARCHAR(30) NOT NULL,
    vehicle TEXT NOT NULL,
    data JSONB,
    garage TEXT,
    active BOOLEAN DEFAULT false NOT NULL,
    items JSONB NOT NULL DEFAULT '{}'::jsonb,
    weapons JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE properties (
    id SERIAL PRIMARY KEY NOT NULL,
    owner VARCHAR(30) NOT NULL,
    internal TEXT,
    x REAL NOT NULL,
    y REAL NOT NULL,
    z REAL NOT NULL,
    locked bool not null default true
);

CREATE TABLE storages(
    id integer not null,
    items jsonb not null default '{}'::jsonb,
    weapons jsonb not null default '{}'::jsonb,
    space integer not null default 0
);

CREATE TABLE outfits(
    id serial primary key NOT NULL,
    owner varchar(30) NOT NULL,
    components jsonb NOT NULL,
    props jsonb NOT NULL,
    created bigint NOT NULL
);

CREATE TABLE funds(
    id serial primary key not null,
    job varchar(16),
    clean bool not null default true,
    total integer not null default 0
);
