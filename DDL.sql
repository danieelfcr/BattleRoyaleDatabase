--DDL PROYECTO
--CREACIÓN DE ESTRUCTURA
use BattleRoyale

--Catálogos
create table Continente(
	idContinente int identity(1,1) primary key,
	nombre varchar(50),
)

create table Pais(
	idPais int identity(1,1) primary key,
	nombre varchar(50),
	idContinente int foreign key references Continente(idContinente)
)

create table Categoria(
	idCategoria int identity(1,1) primary key,
	nombre varchar(50),
)

create table TipoSkin(
	idTipoSkin int identity(1,1) primary key,
	nombre varchar(50),
)

create table Cosmetico(
	idCosmetico int identity(1,1) primary key,
	nombre varchar(50),
	precio decimal,
	idCategoria int foreign key references Categoria(idCategoria),
	idTipoSkin int foreign key references TipoSkin(idTipoSkin)
)

create table TipoPartida(
	idTipoPartida int identity(1,1) primary key,
	nombre varchar(50),
)


--Tablas
create table Plataforma(
	idPlataforma int identity(1,1) primary key,
	nombre varchar(50),
	version varchar(20),
	estado bit
)

create table Usuario(
	idUsuario int identity(1,1) primary key,
	nickname varchar(50) unique,
	nombre1 varchar(50),
	nombre2 varchar(50) null,
	nombre3 varchar(50) null,
	apellido1 varchar(50),
	apellido2 varchar(50),
	email varchar(100),
	contrasena varchar(200),
	fechaNacimiento date,
	estado bit,
	idPais int foreign key references Pais(idPais),
)

create table Conexion(
	idConexion int identity(1,1) primary key,
	fechaLogin datetime,
	fechaLogoff datetime,
	idUsuario int foreign key references Usuario(idUsuario),
	idPlataforma int foreign key references Plataforma(idPlataforma),
)

create table CompraCosmetico(
	idCompraCosmetico int identity(1,1) primary key,
	idCategoria int foreign key references Categoria(idCategoria),
	idTipoSkin int foreign key references TipoSkin(idTipoSkin)
)

create table Partida (
	idPartida int identity(1,1) primary key,
	fechaInicio datetime,
	fechaFin datetime,
	estado bit,
	idGanador int foreign key references Usuario(idUsuario),
	idTipoPartida int foreign key references TipoPartida(idTipoPartida)
)

create table DetallePartida1 (
	idDetPartida1 int identity(1,1) primary key,
	idPartida int foreign key references Partida(idPartida),
	idUsuario int foreign key references Usuario(idUsuario),
	idSkin int foreign key references Cosmetico(idCosmetico),
	idSkinArma int foreign key references Cosmetico(idCosmetico),
)

create table DetallePartida2 (
	idDetPartida2 int identity(1,1) primary key,
	idPartida int foreign key references Partida(idPartida),
	idMuerto int foreign key references Usuario(idUsuario),
	idAsesino int foreign key references Usuario(idUsuario),
	fechaAsesinato datetime
)


