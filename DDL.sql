--DDL PROYECTO
--CREACI�N DE ESTRUCTURA
use BattleRoyale

--Cat�logos
create table Continente(
	idContinente int identity(1,1) primary key,
	nombre varchar(50) not null,
)

create table Pais(
	idPais int identity(1,1) primary key,
	nombre varchar(50) not null,
	idContinente int foreign key references Continente(idContinente) not null
)


-- ======================== DDL para la definici�n de tablas de cosm�ticos ========================
-- categor�a de cosm�ticos: comunes, raros, legendarios...
create table CategoriaCosmetico(
	idCategoriaCosmetico int identity(1,1) primary key,
	nombre varchar(50) not null
)

-- tipo de cosm�tico: skin de arma, skin de personaje etc...
create table TipoCosmetico(
	idTipoCosmetico int identity(1,1) primary key,
	nombre varchar(50) not null
)

-- listado de cosm�ticos: incluye su tipo de cosmetico, su categor�a , nombre y precio
create table Cosmetico(
	idCosmetico int identity(1,1) primary key,
	nombre varchar(50) not null,
	precio decimal not null,
	idCategoriaCosmetico int foreign key references CategoriaCosmetico(idCategoriaCosmetico) not null,
	idTipoCosmetico int foreign key references TipoCosmetico(idTipoCosmetico) not null,
	constraint chk_precio check  (precio >= 0)
)

create table TipoPartida(
	idTipoPartida int identity(1,1) primary key,
	nombre varchar(50) not null,
)


-- DDL para la definici�n de usuarios y conexiones desde una plataforma
create table Plataforma(
	idPlataforma int identity(1,1) primary key,
	nombre varchar(50) not null
)

create table Usuario(
	idUsuario int identity(1,1) primary key,
	nickname varchar(50) unique, -- puede cambiarse cada tres meses 
	nombre1 varchar(50) not null,
	nombre2 varchar(50),
	nombre3 varchar(50),
	apellido1 varchar(50) not null,
	apellido2 varchar(50) not null,
	email varchar(100) not null,
	contrasena varchar(20) not null, 
	fechaNacimiento date not null,
	fechaModificacion date not null, 
	estado bit not null,
	idPais int foreign key references Pais(idPais) not null,
	constraint CK_Usuario_contrasena check(len(contrasena) >= 8),
	constraint CK_Usuario_Edad check(DATEDIFF(YEAR, fechaNacimiento, getdate()) > 12),
	constraint CK_Usuario_Estado check(estado between 0 and 1)
)

-- conexi�n: Guarda el registro de cada una de las conexiones realizadas por los usuarios
create table Conexion(
	idConexion int identity(1,1) primary key,
	fechaLogin datetime not null,
	fechaLogoff datetime not null,
	idUsuario int foreign key references Usuario(idUsuario) not null,
	idPlataforma int foreign key references Plataforma(idPlataforma) not null,
)

-- Guarda un registro de todos los cosm�ticos comprados por alg�n usuario
create table UsuarioCosmetico(
	idUsuarioCosmetico int identity(1,1) primary key,
	idUsuario int foreign key references Usuario(idUsuario) not null,
	idCosmetico int foreign key references Cosmetico(idCosmetico) not null,	
)

create table Partida (
	idPartida int identity(1,1) primary key,
	fechaInicio datetime not null,
	fechaFin datetime not null,
	estado bit not null,
	idGanador int foreign key references Usuario(idUsuario) not null,
	idTipoPartida int foreign key references TipoPartida(idTipoPartida) not null
)

-- tabla que indica los cosm�ticos utilizados durante las partidas de cada usuario
create table DetalleCosmeticoPartida (
	idDetCosmeticoPartida int identity(1,1) primary key,
	idPartida int foreign key references Partida(idPartida) not null,
	idUsuario int foreign key references Usuario(idUsuario) not null,
	idUsuarioCosmetico int foreign key references UsuarioCosmetico(idUsuarioCosmetico) not null,
)

create table DetallePartida (
	idDetallePartida int identity(1,1) primary key,
	idPartida int foreign key references Partida(idPartida) not null,
	idAsesino int foreign key references Usuario(idUsuario),
	idMuerto int foreign key references Usuario(idUsuario) not null,
	fechaAsesinato datetime not null
)

-- Creaci�n de vistas que ser�n utilizadas repeditamente en consultas

-- Key performance indicators (KPIs)
-- a) K/D de un jugador: kills/deaths
go
create view vKillsDeaths 
as
	select idAsesino as 'idUsuario', CAST(count(*) as decimal(2)) / CAST((select count(*) from DetallePartida where idMuerto = dp.idAsesino) as decimal(2)) as 'killDeathRatio'
	from DetallePartida dp	
	group by idAsesino
go
-- b) Tiempo efectivo de juego: cantidad de tiempo en partida / cantidad de tiempo en la plataforma
go
create view vTiempoEfectivoJuego 
as
	select u.idUsuario, (SUM(datediff(MINUTE, c.fechaLogin, c.fechaLogoff)) / SUM(datediff(MINUTE, p.fechaInicio, p.fechaFin))) as 'tiempoEfectivoJuego(minutos)'
	from Usuario u
		inner join Conexion c on (c.idUsuario = u.idUsuario)
		inner join DetallePartida dp on (dp.idAsesino = u.idUsuario)
		inner join Partida p on (p.idPartida = dp.idPartida)
	group by u.idUsuario
go

-- c) Total de compras realizadas para cada cosm�tico
go
create view vTotalComprasCosmetico
as
	select uc.idCosmetico, COUNT(uc.idCosmetico) as 'total compras'
	from UsuarioCosmetico uc
	group by idCosmetico
	
go


-- c) Utilizaci�n efectiva de un cosm�tico: cantidad de usuarios que lo han utilizado en una partida / cantidad de usuarios que lo han comprado
go
create view vUtilizacionEfectivaCosmetico 
as
	select uc.idCosmetico, CAST(COUNT(distinct dcp.idPartida) as decimal(5,2)) / CAST(tcc.[total compras] as decimal(5,2)) as 'utilizaci�n efectiva'
	from DetalleCosmeticoPartida dcp
		inner join UsuarioCosmetico uc on (uc.idUsuarioCosmetico = dcp.idUsuarioCosmetico)
		inner join vTotalComprasCosmetico tcc on (tcc.idCosmetico = uc.idCosmetico)
	group by uc.idCosmetico, tcc.[total compras]
go


-- d) total partidas de cada usuario

go
create view vTotalPartidasUsuario
as
	select dcp.idUsuario, COUNT(distinct dcp.idPartida) as 'total partidas'
	from DetalleCosmeticoPartida dcp
	group by dcp.idUsuario
		
go

-- e) Win ratio: cantidad de partidas ganadas / cantidad de partidas totales
go
create view vWinRatioUsuario
as
	select u.idUsuario, cast(COUNT( p.idGanador) as decimal(2)) / CAST(tpu.[total partidas] as decimal(2)) as 'winRatio' 
	from Usuario u	
		left join Partida p on (p.idGanador = u.idUsuario)
		inner join vTotalPartidasUsuario tpu on (tpu.idUsuario = u.idUsuario)
	group by u.idUsuario, tpu.[total partidas]
go


	

	



	 
	



