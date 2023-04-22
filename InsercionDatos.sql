--INSERCION DATOS EN PROYECTO
use BattleRoyale

-- Insertar continentes
INSERT INTO Continente (nombre)
VALUES ('�frica'), ('Am�rica del Norte'), ('Am�rica del Sur'), ('Asia'), ('Europa'), ('Ocean�a');

-- Insertar pa�ses
INSERT INTO Pais (nombre, idContinent)
VALUES 
('Nigeria', 1),
('Estados Unidos', 2),
('Brasil', 3),
('China', 4),
('Francia', 5),
('Australia', 6),
('Canad�', 2),
('M�xico', 2),
('Argentina', 3),
('Per�', 3),
('Jap�n', 4),
('Corea del Sur', 4),
('Espa�a', 5),
('Reino Unido', 5),
('Italia', 5),
('Alemania', 5),
('Rusia', 5),
('Nueva Zelanda', 6),
('Fiyi', 6),
('Pap�a Nueva Guinea', 6),
('India', 4),
('Indonesia', 4),
('Malasia', 4),
('Sud�frica', 1),
('Egipto', 1),
('Kenia', 1),
('Colombia', 3),
('Venezuela', 3),
('Chile', 3),
('Guatemala', 3);

-- Insertar categor�as
INSERT INTO Categoria(nombre)
VALUES ('Com�n'), ('Raro'), ('Legendario');

-- Insertar tipo de skin
INSERT INTO TipoSkin(nombre)
VALUES ('Personaje'), ('Arma');

-- Insertar tipo de partida
INSERT INTO TipoSkin(nombre)
VALUES ('Normal'), ('Fast'), ('Killer');