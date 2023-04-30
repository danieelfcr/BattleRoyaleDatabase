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

--4. Ranking de jugadores por K/D por continente incluyendo únicamente a jugadores con 10 o más partidas

--5. Ranking de jugadores por Win ratio por continente incluyendo únicamente a jugadores con 10 o más partidas

--6. Ranking de cosméticos por su utilización efectiva
	

--7. Listado de partidas que ha ganado un jugador indicando cantidad de kills

/*8. Listado de jugadores rivales y grado de rivalidad: se define que dos jugadores son rivales si han participado 
en una misma partida 5 o más veces y el grado de rivalidad es la cantidad de partidas que han jugado juntos*/

--9. Promedio de tiempo efectivo de juego por país

--10. Cantidad de partidas en las cuales ha habido al menos un jugador de Asia y uno de América y que uno de estos haya ganado la partida

--11. Cantidad de partidas en las que el ganador tenga 0 kills y algún jugador tenga 10 o más kills

--12. Listado de cosméticos ordenados por tipo, categoría y cantidad de partidas ganadas 

--13. Cantidad de partidas por tiempo de duración en minutos

--14. Top 10 jugadores con más tiempo de juego

--15. Ranking de jugadores según su K/D por rango de edad (13 a 15, 16 a 20, 21 a 25, 26 a 30 y mayores de 30)
