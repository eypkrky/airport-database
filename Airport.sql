-- ULUSLARARASI HAVAALANI VERİTABANI

create table airports (
    airport_id int primary key identity(1,1),
    airport_code nvarchar(10) not null unique,
    airport_name nvarchar(100) not null,
    city nvarchar(50) not null,
    country nvarchar(50) not null
);

create table runways (
    runway_id int primary key identity(1,1),
    airport_id int not null,
    runway_name nvarchar(20) not null,
    length_meters int not null check (length_meters > 0),
    surface_type nvarchar(30) null,
    status nvarchar(20) not null default 'open',
    foreign key (airport_id) references airports(airport_id)
);

create table terminals (
    terminal_id int primary key identity(1,1),
    airport_id int not null,
    terminal_name nvarchar(50) not null,
    foreign key (airport_id) references airports(airport_id)
);

create table gates (
    gate_id int primary key identity(1,1),
    terminal_id int not null,
    gate_number nvarchar(20) not null,
    status nvarchar(20) not null default 'available',
    foreign key (terminal_id) references terminals(terminal_id)
);

create table airlines (
    airline_id int primary key identity(1,1),
    airline_code nvarchar(10) not null unique,
    airline_name nvarchar(100) not null,
    country nvarchar(50) not null
);

create table aircraft_models (
    model_id int primary key identity(1,1),
    model_name nvarchar(50) not null,
    manufacturer nvarchar(50) not null,
    seat_capacity int not null check (seat_capacity > 0),
    max_weight_kg decimal(10,2) not null check (max_weight_kg > 0)
);

create table aircrafts (
    aircraft_id int primary key identity(1,1),
    model_id int not null,
    airline_id int not null,
    tail_number nvarchar(20) not null unique,
    manufacture_year int not null,
    status nvarchar(20) not null default 'active',
    foreign key (model_id) references aircraft_models(model_id),
    foreign key (airline_id) references airlines(airline_id)
);

create table flight_routes (
    route_id int primary key identity(1,1),
    origin_airport_id int not null,
    destination_airport_id int not null,
    distance_km int not null check (distance_km > 0),
    foreign key (origin_airport_id) references airports(airport_id),
    foreign key (destination_airport_id) references airports(airport_id)
);

create table flights (
    flight_id int primary key identity(1,1),
    route_id int not null,
    aircraft_id int not null,
    gate_id int null,
    flight_number nvarchar(20) not null unique,
    departure_time datetime2 not null,
    arrival_time datetime2 not null,
    status nvarchar(20) not null default 'scheduled',
    foreign key (route_id) references flight_routes(route_id),
    foreign key (aircraft_id) references aircrafts(aircraft_id),
    foreign key (gate_id) references gates(gate_id),
    check (arrival_time > departure_time)
);

create table passengers (
    passenger_id int primary key identity(1,1),
    passport_number nvarchar(20) not null unique,
    first_name nvarchar(50) not null,
    last_name nvarchar(50) not null,
    date_of_birth date not null,
    is_blacklisted_security bit not null default 0
);

create table tickets (
    ticket_id int primary key identity(1,1),
    passenger_id int not null,
    flight_id int not null,
    seat_number nvarchar(10) not null,
    price decimal(10,2) not null check (price >= 0),
    purchase_date datetime2 not null,
    foreign key (passenger_id) references passengers(passenger_id),
    foreign key (flight_id) references flights(flight_id)
);

create table baggages (
    baggage_id int primary key identity(1,1),
    ticket_id int not null,
    weight_kg decimal(5,2) not null check (weight_kg >= 0),
    status nvarchar(20) not null default 'checked',
    foreign key (ticket_id) references tickets(ticket_id)
);

create table employees (
    employee_id int primary key identity(1,1),
    airport_id int not null,
    manager_id int null,
    first_name nvarchar(50) not null,
    last_name nvarchar(50) not null,
    job_role nvarchar(50) not null,
    salary decimal(10,2) not null check (salary > 0),
    foreign key (airport_id) references airports(airport_id),
    foreign key (manager_id) references employees(employee_id)
);

create table pilots (
    employee_id int primary key,
    license_number nvarchar(30) not null unique,
    flight_hours_experience int not null check (flight_hours_experience >= 0),
    foreign key (employee_id) references employees(employee_id)
);

create table flight_crews (
    crew_id int primary key identity(1,1),
    flight_id int not null,
    employee_id int not null,
    assignment_role nvarchar(50) not null,
    foreign key (flight_id) references flights(flight_id),
    foreign key (employee_id) references employees(employee_id)
);

create table maintenance_logs (
    log_id int primary key identity(1,1),
    aircraft_id int not null,
    maintenance_date date not null,
    description nvarchar(255) not null,
    cost decimal(10,2) null check (cost >= 0),
    foreign key (aircraft_id) references aircrafts(aircraft_id)
);

go

create view view_flight_details as
select 
    f.flight_number,
    a1.airport_code as origin,
    a2.airport_code as destination,
    f.departure_time,
    f.arrival_time,
    f.status as flight_status,
    g.gate_number
from flights f
join flight_routes r on f.route_id = r.route_id
join airports a1 on r.origin_airport_id = a1.airport_id
join airports a2 on r.destination_airport_id = a2.airport_id
left join gates g on f.gate_id = g.gate_id;

go

create view view_passenger_manifest as
select 
    p.first_name,
    p.last_name,
    t.seat_number,
    t.price as ticket_price,
    b.weight_kg as baggage_weight,
    b.status as baggage_status
from passengers p
join tickets t on p.passenger_id = t.passenger_id
left join baggages b on t.ticket_id = b.ticket_id;

go

create view view_aircraft_fleet as
select 
    a.tail_number,
    m.model_name,
    m.seat_capacity,
    al.airline_name,
    a.manufacture_year,
    a.status
from aircrafts a
join aircraft_models m on a.model_id = m.model_id
join airlines al on a.airline_id = al.airline_id;

go

create view view_runway_status as
select 
    ap.airport_name,
    ap.city,
    r.runway_name,
    r.length_meters,
    r.surface_type,
    r.status
from runways r
join airports ap on r.airport_id = ap.airport_id;

go

create view view_flight_crew_details as
select 
    f.flight_number,
    e.first_name,
    e.last_name,
    e.job_role,
    fc.assignment_role
from flight_crews fc
join flights f on fc.flight_id = f.flight_id
join employees e on fc.employee_id = e.employee_id;

go

create view view_gate_status as
select 
    ap.airport_name,
    t.terminal_name,
    g.gate_number,
    g.status
from gates g
join terminals t on g.terminal_id = t.terminal_id
join airports ap on t.airport_id = ap.airport_id;

go
select * from flights where status = 'delayed';

select * from aircrafts where status = 'maintenance';

select * from passengers where is_blacklisted_security = 1;

select 
    e.first_name, 
    e.last_name, 
    e.salary,
    p.license_number,
    p.flight_hours_experience
from employees e 
join pilots p on e.employee_id = p.employee_id;

select 
    t.ticket_id, 
    t.seat_number,
    b.weight_kg,
    b.status
from tickets t 
join baggages b on t.ticket_id = b.ticket_id 
where b.weight_kg > 20.0;

select 
    m.model_name, 
    m.manufacturer,
    m.seat_capacity,
    a.tail_number,
    a.status
from aircrafts a 
join aircraft_models m on a.model_id = m.model_id;

select 
    p.first_name, 
    p.last_name,
    p.passport_number,
    f.flight_number, 
    t.seat_number,
    t.price,
    a2.airport_name as destination_airport
from passengers p
join tickets t on p.passenger_id = t.passenger_id
join flights f on t.flight_id = f.flight_id
join flight_routes r on f.route_id = r.route_id
join airports a2 on r.destination_airport_id = a2.airport_id;

select 
    f.flight_number,
    f.departure_time,
    f.status as flight_status,
    e.first_name, 
    e.last_name,
    e.job_role,
    fc.assignment_role
from flights f 
join flight_crews fc on f.flight_id = fc.flight_id 
join employees e on fc.employee_id = e.employee_id;

go

insert into airports (airport_code, airport_name, city, country) 
values ('IST', 'Istanbul Airport', 'Istanbul', 'Turkey');

insert into airports (airport_code, airport_name, city, country) 
values ('JFK', 'John F. Kennedy International Airport', 'New York', 'USA');

insert into runways (airport_id, runway_name, length_meters, surface_type, status) 
values (1, '34L', 3750, 'Asphalt', 'open');

insert into runways (airport_id, runway_name, length_meters, surface_type, status) 
values (2, '04R', 2560, 'Concrete', 'open');

insert into terminals (airport_id, terminal_name) 
values (1, 'Main International Terminal');

insert into gates (terminal_id, gate_number, status) 
values (1, 'A12', 'available');

insert into airlines (airline_code, airline_name, country) 
values ('THY', 'Turkish Airlines', 'Turkey');

insert into aircraft_models (model_name, manufacturer, seat_capacity, max_weight_kg) 
values ('Airbus A321neo', 'Airbus', 240, 89000.00);

insert into aircrafts (model_id, airline_id, tail_number, manufacture_year, status) 
values (1, 1, 'TC-JPD', 2022, 'active');

insert into flight_routes (origin_airport_id, destination_airport_id, distance_km) 
values (1, 2, 8000);

insert into flights (route_id, aircraft_id, gate_id, flight_number, departure_time, arrival_time, status) 
values (1, 1, 1, 'TK001', '2026-06-01 13:00:00', '2026-06-01 23:45:00', 'scheduled');

insert into passengers (passport_number, first_name, last_name, date_of_birth, is_blacklisted_security) 
values ('TR123456', 'Ahmet', 'Yilmaz', '1998-05-12', 0);

insert into tickets (passenger_id, flight_id, seat_number, price, purchase_date) 
values (1, 1, '12A', 14500.00, '2026-05-15 09:30:00');

insert into baggages (ticket_id, weight_kg, status) 
values (1, 18.50, 'checked');

insert into employees (airport_id, manager_id, first_name, last_name, job_role, salary) 
values (1, null, 'Can', 'Demir', 'Chief Pilot', 95000.00);

insert into maintenance_logs (aircraft_id, maintenance_date, description, cost)
values (1, '2026-04-10', 'Engine check', 5000.00);

insert into flight_crews (flight_id, employee_id, assignment_role)
values (1, 1, 'Captain');

insert into gates (terminal_id, gate_number, status)
values (1, 'B05', 'available');

insert into aircraft_models (model_name, manufacturer, seat_capacity, max_weight_kg)
values ('Boeing 737', 'Boeing', 180, 70000.00);

go

update flights set status = 'delayed' where flight_id = 1;
update aircrafts set status = 'maintenance' where aircraft_id = 1;
update gates set status = 'occupied' where gate_id = 1;
update employees set salary = 105000.00, job_role = 'Director' where employee_id = 1;
update passengers set is_blacklisted_security = 1 where passenger_id = 1;

delete from maintenance_logs where log_id = 1;
delete from baggages where status = 'delivered';
delete from flight_crews where crew_id = 1;
delete from aircraft_models where model_id = 2;
delete from gates where gate_id = 2;

create nonclustered index idx_flight_number on flights(flight_number);
create nonclustered index idx_passport_number on passengers(passport_number);