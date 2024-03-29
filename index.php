<?php
require 'php-parts/login-check.php';
require 'php-parts/just-for-customer.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="shortcut icon" href="img/icon.png" type="image/x-icon">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.1/css/all.css">
    <link href="https://fonts.googleapis.com/css?family=Fugaz+One|Lato|Nova+Flat|Sofia&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/c-h.css">
    <link rel="stylesheet" href="css/nav.css">
    <link rel="stylesheet" href="css/footer.css">
    <script src="js/search-bar.js"></script>
    <script src="js/cus.js"></script>
    <title>hemsida</title>
</head>
<body>
    <?php require 'html-parts/nav.html';?>
    <main>
        <header>
            <div id="search-bar">
                <input type="text" placeholder="Skriv in artist namn">
                <i class="fas fa-search"></i>
                <button id="filter-button"><i class="fas fa-caret-down"></i>Filter</button>
            </div>
            <div id="filter">
                <select id="selected-country">
                    <option disabled selected value="">Välja ett land</option>
                    <option value="">Alla länder</option>
                </select>
                <select id="selected-city">
                    <option disabled selected value="">Välja en stad</option>
                    <option value="">Alla städer</option>
                </select>
                <select id="selected-scene">
                    <option disabled selected value="">Välja en scene</option>
                    <option value="">Alla scener</option>
                </select><br>
                <div class="date-input">
                    <label for="date">En viss datum</label><br>
                    <input type="date" id="c-date"></div><br>
                <div class="date-input">
                    <label for="f-date">Från och med</label><br>
                    <input type="date" id="f-date">
                </div>
                <div class="date-input">
                    <label for="l-date">Till och med</label><br>
                    <input type="date" id="l-date">
                </div>
            </div>

        </header>
        <div id="content">
        </div>
    </main>
    <?php include 'html-parts/footer.html';?>
    <a id="toTop" href="#"><i class="fas fa-arrow-up" aria-hidden="true"></i></a>
</body>
</html>