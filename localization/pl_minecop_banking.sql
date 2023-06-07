-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Czas generowania: 26 Maj 2021, 20:14
-- Wersja serwera: 10.4.18-MariaDB
-- Wersja PHP: 8.0.3

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Baza danych: `minecop-pack`
--

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `minecop_banking_accounts`
--

CREATE TABLE `minecop_banking_accounts` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `number` varchar(22) NOT NULL,
  `type` int(11) NOT NULL DEFAULT 0,
  `login` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `backupCode` varchar(4) NOT NULL,
  `balance` int(24) NOT NULL DEFAULT 0,
  `percent` double NOT NULL DEFAULT 0,
  `contacts` longtext NOT NULL,
  `isLogged` tinyint(4) NOT NULL DEFAULT 0,
  `lastLogged` varchar(255) DEFAULT NULL,
  `isMain` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktura tabeli dla tabeli `minecop_banking_cards`
--

CREATE TABLE `minecop_banking_cards` (
  `id` int(11) NOT NULL,
  `account` int(11) DEFAULT NULL,
  `number` varchar(14) NOT NULL,
  `pin` varchar(4) NOT NULL,
  `color` varchar(16) NOT NULL DEFAULT "black",
  `paypass` tinyint(4) NOT NULL DEFAULT 0,
  `paypassLimit` int(24) NOT NULL DEFAULT 0,
  `locked` tinyint(4) NOT NULL DEFAULT 0,
  `removed` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indeksy dla zrzutów tabel
--

--
-- Indeksy dla tabeli `minecop_banking_accounts`
--
ALTER TABLE `minecop_banking_accounts`
  ADD PRIMARY KEY (`id`);

--
-- Indeksy dla tabeli `minecop_banking_cards`
--
ALTER TABLE `minecop_banking_cards`
  ADD PRIMARY KEY (`id`),
  ADD KEY `account` (`account`);

--
-- AUTO_INCREMENT dla zrzuconych tabel
--

--
-- AUTO_INCREMENT dla tabeli `minecop_banking_accounts`
--
ALTER TABLE `minecop_banking_accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT dla tabeli `minecop_banking_cards`
--
ALTER TABLE `minecop_banking_cards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Ograniczenia dla zrzutów tabel
--

--
-- Ograniczenia dla tabeli `minecop_banking_cards`
--
ALTER TABLE `minecop_banking_cards`
  ADD CONSTRAINT `minecop_banking_cards_ibfk_1` FOREIGN KEY (`account`) REFERENCES `minecop_banking_accounts` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

INSERT INTO `items`(`name`, `label`, `weight`, `rare`, `can_remove`) VALUES ('card','Karta płatnicza',0,0,1);