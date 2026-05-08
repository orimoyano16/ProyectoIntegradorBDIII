create database asistencia_institucional_db;

create table audit_logs(
	id serial primary key,
	fecha timestamp,
	usuario varchar(35),
	codigo_error varchar(100),
	mensaje_error varchar(100)
);

create table carrera (
	carrera_id serial primary key,
	nombre_carrera varchar(60) not null,
	duracion varchar(35) not null
);

create table usuario (
	usuario_id serial primary key,
	nombre varchar(35) not null,
	apellido varchar(35) not null,
	email varchar(60) not null,
	password_hash text not null,
	dni bigint unique not null,
	rol int not null,
	carrera_id int not null,
	constraint carrera_id
		foreign key (carrera_id)
		references carrera(carrera_id)
);

create table materia (
	materia_id serial primary key,
	nombre varchar(50),
	carrera_id int,
	constraint carrera_id
		foreign key (carrera_id)
		references carrera(carrera_id)
);

create table comision (
	comision_id serial primary key,
	materia_id int,
	constraint fk_comision_materia
		foreign key (materia_id)
		references materia(materia_id),
	profesor_id int,
	constraint profesor_id
		foreign key (profesor_id)
		references usuario(usuario_id),
	turno text,
	aula text,
	ciclo_lectivo int
);

create table inscripcion (
	inscripcion_id serial primary key,
	alumno_id int,
	constraint alumno_id
		foreign key (alumno_id)
		references usuario(usuario_id),
	comision_id int,
	constraint fk_inscripcion_comision
		foreign key (comision_id)
		references comision(comision_id),
	fecha_inscripcion date not null
);

create table asistencia(
	id_asistencia serial primary key,
	alumno_id int,
	constraint alumno_id
		foreign key (alumno_id)
		references usuario(usuario_id),
	comision_id int,
	constraint fk_asistencia_comision
		foreign key (comision_id)
		references comision(comision_id),
	fecha date,
	estado varchar(20),
	observacion text
);
