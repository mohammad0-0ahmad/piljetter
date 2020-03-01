
/*funkar*/
CREATE FUNCTION cancel_concert(concertId integer,give_vouchers boolean)
RETURNS VOID AS $$
BEGIN
IF concertId IS NOT NULL THEN
IF EXISTS (SELECT * FROM concerts WHERE concert_id=concertId AND cancelled=false) then
    IF give_vouchers = true THEN
    INSERT INTO vouchers (user_id) SELECT user_id FROM tickets WHERE concert_id=concertId AND ticket_id IN (SELECT ticket_id FROM pesetas_tickets);
	END IF;
	UPDATE concerts SET cancelled = true WHERE concert_id=concertId;
	END IF;
	END IF;
	END;
$$ LANGUAGE plpgsql;

/*funkar*/
CREATE FUNCTION pesetas_exchanging(money integer)
RETURNS real AS $$
DECLARE
exchangingRate real := 2;
result real := money*exchangingRate;
BEGIN
RETURN result;
END;
$$ language plpgsql;

/*HENRIK*/

/*funkar*/
CREATE FUNCTION  create_wallet(inputtedUserId integer)
RETURNS VOID AS $$
BEGIN
insert into wallets (user_id) VALUES (inputtedUserId);
END;
$$
LANGUAGE 'plpgsql';
/*funkar*/
CREATE FUNCTION  create_user(newUsername varchar, newPassword varchar, newFirstName varchar, newLastName varchar, newEmail varchar,newRole varchar)
RETURNS VOID AS $$
DECLARE
getUserId integer;
getRoleId integer;
BEGIN
getRoleId =  role_id FROM roles WHERE role = newRole;
insert into users (user_name, password, email, first_name, last_name, role_id)
values (newUsername, newPassword, newEmail, newFirstName, newLastName,getRoleId)  returning user_id into getUserId;
IF (newRole = 'customer') THEN PERFORM
create_wallet(getUserId);
END IF;
END;
$$
LANGUAGE 'plpgsql';

/*funkar*/
CREATE FUNCTION best_selling_artists ( fromDate timestamp(6) without time zone, toDate timestamp(6) without time zone)
RETURNS  TABLE (artist_id integer,artist_name varchar,popularity smallint,tickets_sold bigint) AS $$
BEGIN
RETURN QUERY SELECT artists.artist_id,artists.name,artists.popularity,count(*) as tickets_sold
FROM concerts,artists,tickets
   WHERE
       artists.artist_id= concerts.artist_id AND concerts.concert_id = 
	  tickets.concert_id AND tickets.purchase_date > fromDate AND
 tickets.purchase_date < toDate  GROUP BY artists.artist_id,artists.name,artists.popularity ORDER BY tickets_sold DESC LIMIT 10 ; 
END;  $$
LANGUAGE 'plpgsql';

/*funkar*/
CREATE FUNCTION  buy_tickets_with_voucher(new_concert_id integer, new_user_id integer, new_voucher_id integer)
RETURNS VOID AS $$
DECLARE 
get_ticket_id integer;
valid_voucher boolean;
get_expire_date date ;
BEGIN
IF EXISTS (SELECT * FROM concerts where concert_id= new_concert_id AND cancelled=false) THEN
IF EXISTS (SELECT * FROM vouchers WHERE voucher_id = new_voucher_id AND used=false AND user_id=new_user_id) THEN 
valid_voucher = 'true'; 
ELSE RAISE EXCEPTION 'Denna kupong id är ogiltigt.';
END IF;
get_expire_date = expire_date FROM vouchers WHERE  vouchers.voucher_id = new_voucher_id;
IF (valid_voucher = 'true'  AND get_expire_date >= CURRENT_DATE)  THEN
INSERT INTO tickets (concert_id, user_id) VALUES (new_concert_id, new_user_id) returning ticket_id INTO get_ticket_id;
ELSE RAISE EXCEPTION 'Denna kupong är ogiltigt längre.';
END IF;
IF (get_ticket_id IS NOT NULL) THEN
INSERT INTO voucher_tickets (ticket_id,voucher_id) VALUES (get_ticket_id,new_voucher_id);
UPDATE vouchers set used = true WHERE vouchers.voucher_id = new_voucher_id;
END IF;
END IF;
END;
$$
LANGUAGE 'plpgsql';

/*funkar*/
CREATE FUNCTION  buy_tickets_with_pesetas(new_concert_id integer , new_user_id integer)
RETURNS VOID AS $$
DECLARE 
get_ticket_id integer;
actual_ticket_price integer;
get_wallet_balance integer;
BEGIN
IF EXISTS (SELECT * FROM concerts where concert_id= new_concert_id AND cancelled=false) THEN
actual_ticket_price = ticket_price FROM concerts WHERE concerts.concert_id = new_concert_id;
get_wallet_balance = balance FROM wallets WHERE wallets.user_id = new_user_id;
IF (get_wallet_balance >= actual_ticket_price)  THEN
INSERT INTO tickets (concert_id,user_id) VALUES (new_concert_id,new_user_id) returning ticket_id INTO get_ticket_id;
ELSE RAISE EXCEPTION 'Du har inte tillräckligt pesetas';
END IF;
IF (get_ticket_id IS NOT NULL) THEN INSERT INTO pesetas_tickets (ticket_id) VALUES (get_ticket_id);
END IF;
IF (get_ticket_id IS NOT NULL) THEN UPDATE wallets set balance = balance-actual_ticket_price WHERE wallets.user_id = new_user_id;
END IF;
END IF;
END;
$$
LANGUAGE 'plpgsql';
