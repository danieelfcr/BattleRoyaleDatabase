--Consultas
use BattleRoyale

--1. Reporte de cantidad de usuarios por continente
	select c.nombre, count(*) as cantidad
	from Continente c inner join Pais p on (c.idContinente = p.idContinente)
		inner join Usuario u on (p.idPais = u.idPais)
	group by c.nombre

--2. Cantidad de partidas por categoría para un rango de fechas dada
	select tp.nombre, count(*) as cantidad
	from TipoPartida tp inner join Partida p on (tp.idTipoPartida = p.idTipoPartida)
	where month(p.fechaFin) > 2 and  year(p.fechaFin) = 2023
	group by tp.nombre

--3. Cantidad de partidas con menos de 80 jugadores en el último trimestre
	select count(1) as cantidad
	from (
		select p.idPartida, count(distinct idUsuario) as cantidadUsuarios
		from Partida p inner join DetalleCosmeticoPartida dcp on (p.idPartida = dcp.idPartida)
		where DATEDIFF(month, fechaFin, getdate()) <= 3
		group by p.idPartida
		) as X
	where X.cantidadUsuarios < 80  --REVISAR CON DATOS*****

----4 Ranking de jugadores por K/D por continente incluyendo únicamente a jugadores con 10 o más partidas
----COUNT(DISTINCT p.idPartida) cuenta el número de partidas de un jugador
----SUM(CASE WHEN dp.idAsesino = u.idUsuario THEN 1 ELSE 0 END) y SUM(CASE WHEN dp.idMuerto = u.idUsuario THEN 1 ELSE 0 END) cuentan los números de asesinatos y muertes
----NULLIF para evitar errores de división por cero y calcula la relación de asesinatos a muertes
SELECT c.nombre AS continente, u.nickname AS jugador, 
       COUNT(DISTINCT p.idPartida) AS partidas_jugadas, 
       SUM(CASE WHEN dp.idAsesino = u.idUsuario THEN 1 ELSE 0 END) AS asesinatos,
       SUM(CASE WHEN dp.idMuerto = u.idUsuario THEN 1 ELSE 0 END) AS muertes,
       CAST(SUM(CASE WHEN dp.idAsesino = u.idUsuario THEN 1 ELSE 0 END) AS decimal(10,2)) / 
           NULLIF(CAST(SUM(CASE WHEN dp.idMuerto = u.idUsuario THEN 1 ELSE 0 END) AS decimal(10,2)), 0) AS ratio
FROM Continente_ c
JOIN Pais_ pa ON c.idContinente = pa.idContinente
JOIN Usuario_ u ON pa.idPais = u.idPais
JOIN Conexion_ co ON u.idUsuario = co.idUsuario
JOIN Partida_ p ON co.idConexion = p.idGanador
JOIN DetallePartida_ dp ON p.idPartida = dp.idPartida
GROUP BY c.nombre, u.nickname;

--5. Ranking de jugadores por Win ratio por continente incluyendo únicamente a jugadores con 10 o más partidas
---INNER JOIN entre la tabla Usuario y las tablas Continente y Pais, obtiene información geográfica de cada usuario
---LEFT JOIN con la tabla Partida, y se utiliza COUNT y CASE para contar el número total de partidas
---se calcula el porcentaje de victorias (WinRatio) dividiendo el número de victorias por el número total de partidas (exceptuando las partidas que no han sido completadas)

SELECT U.idUsuario, U.nickname, P.nombre AS pais, C.nombre AS continente,
    COUNT(DP.idDetallePartida) AS TotalPartidas,
    COUNT(CASE WHEN DP.idAsesino IS NOT NULL AND DP.idMuerto IS NOT NULL AND DP.idAsesino = U.idUsuario THEN 1 END) AS TotalVictorias,
    COUNT(CASE WHEN DP.idAsesino IS NOT NULL AND DP.idMuerto IS NOT NULL AND DP.idAsesino != U.idUsuario THEN 1 END) AS TotalDerrotas,
    CONVERT(DECIMAL(18,2), COUNT(CASE WHEN DP.idAsesino IS NOT NULL AND DP.idMuerto IS NOT NULL AND DP.idAsesino = U.idUsuario THEN 1 END)) / NULLIF(CONVERT(DECIMAL(18,2), COUNT(DP.idDetallePartida)),0) AS WinRatio
FROM Usuario U
INNER JOIN Pais P ON P.idPais = U.idPais
INNER JOIN Continente C ON C.idContinente = P.idContinente
INNER JOIN Partida PA ON PA.idGanador = U.idUsuario
INNER JOIN DetallePartida DP ON DP.idPartida = PA.idPartida AND DP.idMuerto = U.idUsuario
WHERE U.estado = 1
GROUP BY U.idUsuario, U.nickname, P.nombre, C.nombre
HAVING COUNT(DP.idDetallePartida) >= 10
ORDER BY WinRatio DESC



--6. Ranking de cosméticos por su utilización efectiva
----consulta  DetalleCosmeticoPartida_ para obtener registros de cosméticos utilizados por usuarios durante las partidas
----inner join con la tabla UsuarioCosmetico_ para obtener cosméticos que cada usuario posee
----inner join  con la tabla Cosmetico_ para obtener el nombre de cada cosmético
----count(*)cuenta la cantidad de veces que cada cosmético ha sido utilizado en las partidas
SELECT c.nombre AS nombre_cosmetico, COUNT(*) AS veces_utilizado
FROM DetalleCosmeticoPartida dcp
INNER JOIN UsuarioCosmetico uc ON dcp.idUsuarioCosmetico = uc.idUsuarioCosmetico
INNER JOIN Cosmetico c ON uc.idCosmetico = c.idCosmetico
GROUP BY c.nombre
ORDER BY veces_utilizado DESC



--7. Listado de partidas que ha ganado un jugador indicando cantidad de kills
----join de tablas "Partida" y "DetallePartida" mediante la columna "idPartida"
----where filtra por el ID del asesino ganador

SELECT P.idPartida, COUNT(DP.idMuerto) as cantidad_kills
FROM Partida P
JOIN DetallePartida DP ON P.idPartida = DP.idPartida
WHERE P.idGanador = [idasesino]
GROUP BY P.idPartida


--8. Listado de jugadores rivales y grado de rivalidad: se define que dos jugadores son rivales si han participado  en una misma partida 5 o más veces y el grado de rivalidad es la cantidad de partidas que han jugado juntos*/

----C1 se une con U1 para obtener los datos del jugador 1.
----C2 se une con C1 para obtener los datos de la conexión que tuvo lugar para el jugador 1.
----C2 se une con U2 para obtener los datos del jugador 2.
----C1 se une con P para obtener los datos de las partidas jugadas.
----La condición C2.idUsuario <> U1.idUsuario se utiliza para asegurarse de que el jugador 2 no sea el mismo que el jugador 1.
---- HAVING COUNT(DISTINCT P.idPartida) >= 5 se utiliza para limitar los resultados a aquellos pares de jugadores que hayan jugado al menos 5 partidas juntos.
SELECT 
    U1.idUsuario AS idJugador1, 
    U1.nickname AS Jugador1, 
    U2.idUsuario AS idJugador2, 
    U2.nickname AS Jugador2,
    COUNT(DISTINCT P.idPartida) AS GradoRivalidad
FROM Usuario_ U1
INNER JOIN Conexion C1 ON U1.idUsuario = C1.idUsuario
INNER JOIN Conexion C2 ON C1.idConexion = C2.idConexion AND C2.idUsuario <> U1.idUsuario
INNER JOIN Partida P ON C1.idConexion = C2.idConexion
INNER JOIN Usuario U2 ON C2.idUsuario = U2.idUsuario
GROUP BY U1.idUsuario, U1.nickname, U2.idUsuario, U2.nickname
HAVING COUNT(DISTINCT P.idPartida) >= 5


	

--9. Promedio de tiempo efectivo de juego por país
----9 Promedio de tiempo efectivo de juego por país
----join tablas de Usuario, Conexion, Partida y Pais
----Partida_.estado = 1 filtro de partidas finalizadas
----DATEDIFF() para calcular el tiempo y AVG para el promedio
SELECT Pais.nombre as Pais, 
       AVG(DATEDIFF(MINUTE, Conexion.fechaLogin, Partida.fechaFin)) as PromedioTiempoJuego
FROM Usuario
JOIN Conexion ON Usuario.idUsuario = Conexion.idUsuario 
JOIN Partida ON Partida.idGanador = Usuario.idUsuario 
JOIN Pais ON Pais.idPais = Usuario.idPais
WHERE Partida.estado = 1 -- se consideran solo las partidas finalizadas
GROUP BY Pais.nombre


--10. Cantidad de partidas en las cuales ha habido al menos un jugador de Asia y uno de América y que uno de estos haya ganado la partida
---se seleccionan los id de partida distintos donde un jugador muere y pertenece a Asia o América, utilizando las tablas Partida_, DetallePartida_, Usuario_ y Pais_
---WHERE especifica que se deben buscar partidas en las que el país de origen del jugador muerto pertenece a uno de los dos continentes mencionados
--- se une el resultado anterior con la tabla Partida_ para obtener más información sobre las partidas que cumplen con los criterios anteriores
---se une con las tablas Usuario_ y Pais_ para obtener información sobre el ganador de cada partida y su país de origen
---se cuenta la cantidad de registros resultantes en la tabla subconsulta
SELECT COUNT(*) AS CantidadDePartidas
FROM (
    SELECT DISTINCT p.idPartida
    FROM Partida p
    INNER JOIN DetallePartida dp ON p.idPartida = dp.idPartida
    INNER JOIN Usuario u ON u.idUsuario = dp.idMuerto
    INNER JOIN Pais pa ON pa.idPais = u.idPais
    WHERE pa.idContinente = (
        SELECT c.idContinente
        FROM Continente c
        WHERE c.nombre = 'Asia'
    ) OR pa.idContinente = (
        SELECT c.idContinente
        FROM Continente c
        WHERE c.nombre = 'América'
    )
) AS subq
INNER JOIN Partida p ON subq.idPartida = p.idPartida
INNER JOIN Usuario u ON p.idGanador = u.idUsuario
INNER JOIN Pais pa ON pa.idPais = u.idPais
WHERE pa.idContinente = (
    SELECT c.idContinente
    FROM Continente c
    WHERE c.nombre = 'Asia'
) OR pa.idContinente = (
    SELECT c.idContinente
    FROM Continente c
    WHERE c.nombre = 'América'
)
--11. Cantidad de partidas en las que el ganador tenga 0 kills y algún jugador tenga 10 o más kills

--12. Listado de cosméticos ordenados por tipo, categoría y cantidad de partidas ganadas 

--13. Cantidad de partidas por tiempo de duración en minutos

--14. Top 10 jugadores con más tiempo de juego

--15. Ranking de jugadores según su K/D por rango de edad (13 a 15, 16 a 20, 21 a 25, 26 a 30 y mayores de 30)
