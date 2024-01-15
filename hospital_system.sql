
/*
 Sobirov Nurmuhammad
 v-1
 https://drawsql.app/teams/uzclan/diagrams/hospital-system-sql
 */



CREATE TABLE "patient"(
                          "id" bigserial primary key NOT NULL,
                          "first_name" VARCHAR(255) NOT NULL,
                          "last_name" VARCHAR(255) NOT NULL
);


CREATE TABLE "appointment"(
                              "id" bigserial primary key NOT NULL,
                              "patient_id" BIGINT references patient(id),
                              "staff_id" BIGINT references staff(id),
                              "appointment_date" DATE NOT NULL
);


CREATE TABLE "staff"(
                        "id" bigserial primary key NOT NULL,
                        "first_name" VARCHAR(255) NOT NULL,
                        "last_name" VARCHAR(255) NOT NULL
);

INSERT INTO patient(first_name, last_name)
values
    ('Alan','Johnson'),('Aziz','Qurbonov'),
    ('Ali','Valiyev'),('George','Washington'),
    ('Benjamin','Franklyn'),('Andrew','Ted');

INSERT INTO staff(first_name, last_name)
values
    ('Billy','Ford'),('Doctor','House'),
    ('Anatole','Simson');


INSERT INTO appointment(patient_id, staff_id, appointment_date)
VALUES
    (2,1,date('2023-12-01')),(3,2,date('2024-02-13')),
    (5,3,date('2024-10-21')),(6,1,now());

CREATE OR REPLACE FUNCTION fn_search_patient_by_name(
    in p_name varchar(255)
)

returns table(
    p_first_name varchar(255),
    p_last_name varchar(255)
             )
language plpgsql
as
    $$
begin
return query
select first_name, last_name from patient
where first_name like '%'||p_name||'%' or last_name like '%'||p_name||'%';
end
    $$;

select * from fn_search_patient_by_name('i');


CREATE OR REPLACE procedure pr_schedule_appointment(
    p_id bigint,
    s_id bigint,
    a_date date
)
language plpgsql
as
    $$
begin
INSERT INTO appointment(patient_id, staff_id, appointment_date)
values (p_id, s_id, a_date);
end
    $$;

call pr_schedule_appointment(p_id := 3, s_id := 3, a_date := date('2024-03-16'));

select * from appointment;

CREATE or replace view appointments_for_today
as
SELECT * from appointment
where appointment_date=current_date;

select * from appointments_for_today;


CREATE materialized view every_patient_appointment_count_last_month
as
select first_name||' '|| last_name patient, count(a.id) count_of_appointments,
       extract(month from appointment_date) "month", extract(year from appointment_date) "year"
from appointment a
         inner join patient p on p.id = a.patient_id
where extract(month from appointment_date) = extract(month from current_date)-1
group by patient_id, first_name,last_name, month,year;


refresh materialized view every_patient_appointment_count_last_month;

select * from every_patient_appointment_count_last_month;
