-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Окт 27 2026 г., 23:54
-- Версия сервера: 5.7.21-20-beget-5.7.21-20-1-log
-- Версия PHP: 8.3.36

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `helprogl_contein`
--

-- --------------------------------------------------------

--
-- Структура таблицы `game__container`
--
-- Создание: Окт 27 2026 г., 16:40
-- Последнее обновление: Окт 27 2026 г., 20:49
--

DROP TABLE IF EXISTS `game__container`;
CREATE TABLE `game__container` (
  `id` int(11) NOT NULL,
  `cModel` int(11) NOT NULL,
  `cPosX` float NOT NULL,
  `cPosY` float NOT NULL,
  `cPosZ` float NOT NULL,
  `cPosRX` float NOT NULL DEFAULT '0',
  `cPosRY` float NOT NULL DEFAULT '0',
  `cPosRZ` float NOT NULL DEFAULT '0',
  `cVW` int(11) NOT NULL DEFAULT '0',
  `cInt` int(11) NOT NULL DEFAULT '0',
  `cTime` int(11) NOT NULL DEFAULT '0',
  `cStartPrice` int(11) NOT NULL DEFAULT '0',
  `cType` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `game__container_bid`
--
-- Создание: Окт 27 2026 г., 20:21
-- Последнее обновление: Окт 27 2026 г., 20:49
--

DROP TABLE IF EXISTS `game__container_bid`;
CREATE TABLE `game__container_bid` (
  `containerId` int(11) NOT NULL,
  `username` varchar(24) NOT NULL,
  `count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `game__container_log`
--
-- Создание: Окт 27 2026 г., 18:59
-- Последнее обновление: Окт 27 2026 г., 20:49
--

DROP TABLE IF EXISTS `game__container_log`;
CREATE TABLE `game__container_log` (
  `id` int(10) UNSIGNED NOT NULL,
  `text` text NOT NULL,
  `createdAt` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `game__container_loot`
--
-- Создание: Окт 27 2026 г., 19:21
--

DROP TABLE IF EXISTS `game__container_loot`;
CREATE TABLE `game__container_loot` (
  `id` int(11) NOT NULL,
  `iName` varchar(32) NOT NULL,
  `iAmount` int(11) NOT NULL,
  `iPercent` float NOT NULL,
  `iLootType` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `game__container_loot`
--

INSERT INTO `game__container_loot` (`id`, `iName`, `iAmount`, `iPercent`, `iLootType`) VALUES
(1, 'Деньги', 100000, 20.1, 1),
(2, 'Деньги', 1000000, 20.1, 2),
(3, 'Деньги', 10000000, 20.1, 3);

-- --------------------------------------------------------

--
-- Структура таблицы `game__container_loot_winner`
--
-- Создание: Окт 27 2026 г., 19:21
-- Последнее обновление: Окт 27 2026 г., 20:49
--

DROP TABLE IF EXISTS `game__container_loot_winner`;
CREATE TABLE `game__container_loot_winner` (
  `username` varchar(24) NOT NULL,
  `lootid` int(11) NOT NULL,
  `conteinerId` int(11) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `game__container_type`
--
-- Создание: Окт 27 2026 г., 15:13
-- Последнее обновление: Окт 27 2026 г., 15:26
--

DROP TABLE IF EXISTS `game__container_type`;
CREATE TABLE `game__container_type` (
  `id` int(11) NOT NULL,
  `typeName` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `game__container_type`
--

INSERT INTO `game__container_type` (`id`, `typeName`) VALUES
(1, 'Обычный'),
(2, 'Редкий'),
(3, 'ОООООчень редкий'),
(4, 'Супер редкий');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `game__container`
--
ALTER TABLE `game__container`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cType` (`cType`);

--
-- Индексы таблицы `game__container_log`
--
ALTER TABLE `game__container_log`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `game__container_loot`
--
ALTER TABLE `game__container_loot`
  ADD PRIMARY KEY (`id`),
  ADD KEY `iLootType` (`iLootType`);

--
-- Индексы таблицы `game__container_loot_winner`
--
ALTER TABLE `game__container_loot_winner`
  ADD KEY `lootid` (`lootid`),
  ADD KEY `conteinerId` (`conteinerId`);

--
-- Индексы таблицы `game__container_type`
--
ALTER TABLE `game__container_type`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `game__container`
--
ALTER TABLE `game__container`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `game__container_log`
--
ALTER TABLE `game__container_log`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `game__container_loot`
--
ALTER TABLE `game__container_loot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT для таблицы `game__container_type`
--
ALTER TABLE `game__container_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `game__container`
--
ALTER TABLE `game__container`
  ADD CONSTRAINT `game__container_ibfk_1` FOREIGN KEY (`cType`) REFERENCES `game__container_type` (`id`);

--
-- Ограничения внешнего ключа таблицы `game__container_loot`
--
ALTER TABLE `game__container_loot`
  ADD CONSTRAINT `game__container_loot_ibfk_1` FOREIGN KEY (`iLootType`) REFERENCES `game__container_type` (`id`);

--
-- Ограничения внешнего ключа таблицы `game__container_loot_winner`
--
ALTER TABLE `game__container_loot_winner`
  ADD CONSTRAINT `game__container_loot_winner_ibfk_1` FOREIGN KEY (`lootid`) REFERENCES `game__container_loot` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
