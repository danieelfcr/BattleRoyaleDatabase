--INSERCION DATOS EN PROYECTO
use BattleRoyale

-- Insertar continentes
INSERT INTO Continente (nombre)
VALUES ('África'), ('América del Norte'), ('América del Sur'), ('Asia'), ('Europa'), ('Oceanía');

-- Insertar países
INSERT INTO Pais (nombre, idContinent)
VALUES 
('Nigeria', 1),
('Estados Unidos', 2),
('Brasil', 3),
('China', 4),
('Francia', 5),
('Australia', 6),
('Canadá', 2),
('México', 2),
('Argentina', 3),
('Perú', 3),
('Japón', 4),
('Corea del Sur', 4),
('España', 5),
('Reino Unido', 5),
('Italia', 5),
('Alemania', 5),
('Rusia', 5),
('Nueva Zelanda', 6),
('Fiyi', 6),
('Papúa Nueva Guinea', 6),
('India', 4),
('Indonesia', 4),
('Malasia', 4),
('Sudáfrica', 1),
('Egipto', 1),
('Kenia', 1),
('Colombia', 3),
('Venezuela', 3),
('Chile', 3),
('Guatemala', 3);

-- Insertar categorías
INSERT INTO Categoria(nombre)
VALUES ('Común'), ('Raro'), ('Legendario');

-- Insertar tipo de skin
INSERT INTO TipoSkin(nombre)
VALUES ('Personaje'), ('Arma');

-- Insertar tipo de partida
INSERT INTO TipoSkin(nombre)
VALUES ('Normal'), ('Fast'), ('Killer');