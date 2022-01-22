------- My code --------
create table delivery(
	delivery_id serial primary key,
	address_id int not null references address(address_id),
	staff_id int not null references staff(staff_id),
	delivery_date date not null,
	deivery_time time[] not null,
	status del_status not null default 'в обработке',
	last_update timestamp,
	create_date  timestamp not null default now(),
	deleted boolean not null default false
	)

------- Create code frome Postgres -------

-- Table: rodionov_v.delivery

-- DROP TABLE IF EXISTS rodionov_v.delivery;

CREATE TABLE IF NOT EXISTS rodionov_v.delivery
(
    delivery_id integer NOT NULL DEFAULT nextval('rodionov_v.delivery_delivery_id_seq'::regclass),
    address_id integer NOT NULL,
    staff_id integer NOT NULL,
    delivery_date date NOT NULL,
    deivery_time time without time zone[] NOT NULL,
    status rodionov_v.del_status NOT NULL DEFAULT 'в обработке'::rodionov_v.del_status,
    last_update timestamp without time zone,
    create_date timestamp without time zone NOT NULL DEFAULT now(),
    deleted boolean NOT NULL DEFAULT false,
    CONSTRAINT delivery_pkey PRIMARY KEY (delivery_id),
    CONSTRAINT delivery_address_id_fkey FOREIGN KEY (address_id)
        REFERENCES rodionov_v.address (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT delivery_staff_id_fkey FOREIGN KEY (staff_id)
        REFERENCES rodionov_v.staff (staff_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS rodionov_v.delivery
    OWNER to postgres;