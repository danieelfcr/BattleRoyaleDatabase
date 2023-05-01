
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
	where X.cantidadUsuarios < 80  

--4. Ranking de jugadores por K/D por continente incluyendo únicamente a jugadores con 10 o más partidas

select c.nombre, u.nickname, kd.killDeathRatio
from vKillsDeaths kd
	inner join Usuario u on (u.idUsuario = kd.idUsuario)
	inner join Pais p on (p.idPais = u.idPais)
	inner join Continente c on (c.idContinente = p.idContinente)
	inner join vTotalPartidasUsuario tpu on (tpu.idUsuario = u.idUsuario)
where tpu.[total partidas] > 10
group by c.nombre, u.nickname, kd.killDeathRatio
order by c.nombre, kd.killDeathRatio desc



--5. Ranking de jugadores por Win ratio por continente incluyendo únicamente a jugadores con 10 o más partidas
select c.nombre, u.nickname, wru.WinRatio
from vWinRatioUsuario wru
	inner join Usuario u on (u.idUsuario = wru.idUsuario)
	inner join Pais p on (p.idPais = u.idPais)
	inner join Continente c on (c.idContinente = p.idContinente)
	inner join vTotalPartidasUsuario tpu on (tpu.idUsuario = u.idUsuario)
where tpu.[total partidas] > 10
group by c.nombre, u.nickname, wru.WinRatio
order by c.nombre, wru.WinRatio desc




--6. Ranking de cosméticos por su utilización efectiva
----consulta  DetalleCosmeticoPartida_ para obtener registros de cosméticos utilizados por usuarios durante las partidas
----inner join con la tabla UsuarioCosmetico_ para obtener cosméticos que cada usuario posee
----inner join  con la tabla Cosmetico_ para obtener el nombre de cada cosmético
----count(*)cuenta la cantidad de veces que cada cosmético ha sido utilizado en las partidas
SELECT c.nombre AS 'nombre cosmetico', COUNT(*) AS 'veces utilizado'
FROM DetalleCosmeticoPartida dcp
INNER JOIN UsuarioCosmetico uc ON dcp.idUsuarioCosmetico = uc.idUsuarioCosmetico
INNER JOIN Cosmetico c ON uc.idCosmetico = c.idCosmetico
GROUP BY c.nombre
ORDER BY 'veces utilizado' DESC



--7. Listado de partidas que ha ganado un jugador indicando cantidad de kills
----join de tablas "Partida" y "DetallePartida" mediante la columna "idPartida"
----where filtra por el ID del asesino ganador

select p.idPartida, u.nickname as 'ganador',  COUNT(*) as 'kills' 
from DetallePartida dp 
	inner join Partida p on (p.idPartida = dp.idPartida)
	inner join Usuario u on (u.idUsuario = p.idGanador)
where dp.idAsesino = p.idGanador and dp.idPartida = p.idPartida
group by p.idPartida, u.nickname
order by p.idPartida



--8. Listado de jugadores rivales y grado de rivalidad: se define que dos jugadores son rivales si han participado  en una misma partida 5 o más veces y el grado de rivalidad es la cantidad de partidas que han jugado juntos*/

SELECT DC1.idUsuario AS Jugador1, DC2.idUsuario AS Jugador2, COUNT(*) AS GradoRivalidad
FROM
    DetalleCosmeticoPartida DC1
     JOIN DetalleCosmeticoPartida DC2
        ON DC1.idPartida = DC2.idPartida
         AND DC1.idUsuario < DC2.idUsuario
WHERE DC1.idUsuario <> DC2.idUsuario
GROUP BY  DC1.idUsuario,DC2.idUsuario
HAVING COUNT(*) >= 5
ORDER BY COUNT(*) DESC
 



--9. Promedio de tiempo efectivo de juego por país

select ps.nombre,  AVG(tej.[tiempoEfectivoJuego(minutos)]) as 'promedio tiempo Efectivo de Juego (minutos)'
from Pais ps
	inner join Usuario u on (u.idPais = ps.idPais)
	inner join vTiempoEfectivoJuego tej on (tej.idUsuario = u.idUsuario)
group by ps.nombre
order by ps.nombre



--10. Cantidad de partidas en las cuales ha habido al menos un jugador de Asia y uno de América y que uno de estos haya ganado la partida

-- variables utilizadas para el cursor
declare @vIdPartida int, @vIdGanador int, @vContinente varchar(50), @vBanderaAsia bit = 0, @vBanderaAmerica bit = 0, @vUsuario int, @vContinenteUsuario varchar(50), @vIdPartidaAnterior int, @vContador int = 0

-- declaración del cursor y su query base
declare c_partidas cursor for
	select p.idPartida, p.idGanador, c.nombre
	from Partida p
		inner join Usuario u on (p.idGanador = u.idUsuario)
		inner join Pais pa on (pa.idPais = u.idPais)
		inner join Continente c on (c.idContinente = pa.idContinente)
	where c.nombre = 'Asia' or c.nombre like '%América%'

-- apertura cursor
open c_partidas

-- ciclo de recorrido
fetch c_partidas into @vIdPartida, @vIdGanador, @vContinente
	while (@@FETCH_STATUS = 0)
	begin		

		select distinct  @vUsuario = dp.idUsuario, @vContinenteUsuario = c.nombre
		from DetalleCosmeticoPartida dp
			inner join Usuario u on (u.idUsuario = dp.idUsuario)
			inner join Pais p on (p.idPais = u.idPais)
			inner join Continente c on (c.idContinente = p.idContinente)
		where dp.idPartida = @vIdPartida

		-- asignación de variables bandera
		if (@vContinenteUsuario = 'Asia')
		begin
			set @vBanderaAsia = 1 
		end
		if (@vContinenteUsuario like '%América%')
		begin
			set @vBanderaAmerica = 1 
		end

		-- se guarda la partida anterior para saber cuando dejar de utilizar la variable contador
		set @vIdPartidaAnterior = @vIdPartida
		fetch c_partidas into @vIdPartida, @vIdGanador, @vContinente


		-- se verifica que hay un cambio de partida y antes de recorrer la nueva partida se verifica que ambas banderas tengan un valor de 1, indicando que había mínimo un jugador de Asia y uno de América
		if (@vIdPartidaAnterior != @vIdPartida and @vBanderaAsia = 1  and @vBanderaAmerica = 1)
		begin
			set @vContador = @vContador + 1
		end	
	end
	print @vContador

close c_partidas
deallocate c_partidas



--11. Cantidad de partidas en las que el ganador tenga 0 kills y algún jugador tenga 10 o más kills



--12. Listado de cosméticos ordenados por tipo, categoría y cantidad de partidas ganadas 
----JOINS en tablas: Cosmetico, TipoCosmetico, CategoriaCosmetico, UsuarioCosmetico y Partida

SELECT TC.nombre AS tipo_cosmetico, CC.nombre AS categoria_cosmetico, C.nombre AS nombre_cosmetico, COUNT(*) AS partidas_ganadas
FROM Cosmetico_ C
INNER JOIN TipoCosmetico_ TC ON C.idTipoCosmetico = TC.idTipoCosmetico
INNER JOIN CategoriaCosmetico_ CC ON C.idCategoriaCosmetico = CC.idCategoriaCosmetico
INNER JOIN UsuarioCosmetico_ UC ON C.idCosmetico = UC.idCosmetico
INNER JOIN DetalleCosmeticoPartida_ DCP ON UC.idUsuarioCosmetico = DCP.idUsuarioCosmetico
INNER JOIN Partida_ P ON DCP.idPartida = P.idPartida
WHERE P.idGanador = DCP.idUsuario
GROUP BY TC.nombre, CC.nombre, C.nombre
ORDER BY TC.nombre, CC.nombre, COUNT(*) DESC
--13. Cantidad de partidas por tiempo de duración en minutos

--14. Top 10 jugadores con más tiempo de juego
select top 10  u.nickname, SUM(datediff(MINUTE, p.fechaInicio, p.fechaFin)) as 'tiempo de juego (minutos)'
	from Usuario u
		inner join Conexion c on (c.idUsuario = u.idUsuario)
		inner join DetallePartida dp on (dp.idAsesino = u.idUsuario)
		inner join Partida p on (p.idPartida = dp.idPartida)
	group by u.nickname
	order by SUM(datediff(MINUTE, p.fechaInicio, p.fechaFin)) desc


--15. Ranking de jugadores según su K/D por rango de edad (13 a 15, 16 a 20, 21 a 25, 26 a 30 y mayores de 30)

SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, u.fechaNacimiento, GETDATE()) BETWEEN 13 AND 15 THEN '13-15'
        WHEN DATEDIFF(YEAR, u.fechaNacimiento, GETDATE()) BETWEEN 16 AND 20 THEN '16-20'
        WHEN DATEDIFF(YEAR, u.fechaNacimiento, GETDATE()) BETWEEN 21 AND 25 THEN '21-25'
        WHEN DATEDIFF(YEAR, u.fechaNacimiento, GETDATE()) BETWEEN 26 AND 30 THEN '26-30'
        ELSE 'Mayor de 30'
    END AS rangoEdad,
    u.nickname,
	kd.killDeathRatio
FROM 
    Usuario u
    inner join vKillsDeaths kd on (kd.idUsuario = u.idUsuario)
WHERE 
    DATEDIFF(YEAR, fechaNacimiento, GETDATE()) >= 13
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, fechaNacimiento, GETDATE()) BETWEEN 13 AND 15 THEN '13-15'
        WHEN DATEDIFF(YEAR, fechaNacimiento, GETDATE()) BETWEEN 16 AND 20 THEN '16-20'
        WHEN DATEDIFF(YEAR, fechaNacimiento, GETDATE()) BETWEEN 21 AND 25 THEN '21-25'
        WHEN DATEDIFF(YEAR, fechaNacimiento, GETDATE()) BETWEEN 26 AND 30 THEN '26-30'
        ELSE 'Mayor de 30'
    END,
    u.nickname,
	kd.killDeathRatio
ORDER BY 
    rangoEdad ASC, kd.killDeathRatio DESC
