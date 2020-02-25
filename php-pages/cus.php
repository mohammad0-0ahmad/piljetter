<?php
require '../php-parts/login-check.php';
require '../php-parts/db-connection.php';
require '../php-parts/obj.php';
//get user information
$sql= "SELECT concat(u.first_name,' ',u.last_name) AS NAME,w.balance FROM users AS u,wallets AS w WHERE u.user_id=w.user_id AND u.user_id = $_SESSION[userId]";
$stmt = $conn->prepare($sql);
$stmt->execute();
//should return just one row.
$row = $stmt->fetch(PDO::FETCH_ASSOC);
$user= new user($row['name'],$row['balance']);

$sql ="SELECT t.ticket_id,
a.name AS artist_name, s.name AS scene_name, ci.city, ci.country, c.date, c.time, c.ticket_price,
t.purchase_date FROM pesetas_tickets as pt,  users as u,
artists as a, scenes as s, cities as ci, tickets as t, concerts as c
WHERE pt.ticket_id=t.ticket_id  AND t.user_id = u.user_id AND
a.artist_id = c.artist_id AND s.scene_id = c.scene_id AND
ci.city_id = s.city_id AND t.concert_id = c.concert_id AND t.user_id = $_SESSION[userId];";
$stmt = $conn->prepare($sql);
$stmt->execute();
$tickets = array();
$i=0;
while($row = $stmt->fetch(PDO::FETCH_ASSOC)){
    $tickets[$i] = new ticket($row['ticket_id'],$row['artist_name'],$row['scene_name'],$row['city'],$row['country'],$row['date'],$row['time'],$row['ticket_price'],$row['purchase_date']);
    $getDate =$tickets{$i}->purchaseDate;
    $createDate = new DateTime($getDate);
    $dateObj = $createDate->format("Y-m-d");
    $tickets{$i}->purchaseDate = $dateObj;
    $i++;
}


$sql ="select voucher_id, issued_date, expire_date, used from vouchers WHERE vouchers.user_id = $_SESSION[userId];";
$stmt = $conn->prepare($sql);
$stmt->execute();
$vouchers = array();
$i=0;
while($row = $stmt->fetch(PDO::FETCH_ASSOC)){
    $vouchers[$i] = new voucher($row['voucher_id'],$row['issued_date'],$row['expire_date'],$row['used']);
    $i++;
}

//printing result as json
echo '{"user":';
echo json_encode($user,JSON_PRETTY_PRINT);
echo ',"tickets":';
echo json_encode($tickets,JSON_PRETTY_PRINT);
echo ',"vouchers":';
echo json_encode($vouchers,JSON_PRETTY_PRINT);
echo "}";
$conn =null;
$stmt =null;
?>