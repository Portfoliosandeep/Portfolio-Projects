use pizzadb;
#Dashboard1-order activity
select 
o.order_id,
i.item_price,
o.quantity,
i.item_cat,
i.item_name,
o.created_at,
a.delivery_address1,
a.delivery_address2,
a.delivery_city,
a.delivery_zipcode,
o.delivery
from orders o 
left join item i on o.item_id=i.item_id
LEFT JOIN address a on o.add_id=a.add_id;

#Dashboard2-Iventory Management 
with s1 as(select 
o.item_id,
i.sku,
i.item_name,
r.ing_id,
ing.ing_name,
r.quantity as receipe_quantity,
sum(o.quantity) as order_quantity,
ing.ing_weight,
ing.ing_price
from orders o 
LEFT JOIN item i on o.item_id=i.item_id
left join recipe r on i.sku=r.recipe_id
LEFT JOIN ingredient ing on ing.ing_id=r.ing_id
group by o.item_id,i.sku,i.item_name,r.ing_id,r.quantity,ing.ing_name,ing.ing_weight,
ing.ing_price)

select *,
order_quantity*receipe_quantity as ordered_weight,
ing_price/ing_weight as unit_cost,
(order_quantity*receipe_quantity)*( ing_price/ing_weight) as ingredient_cost
from s1;

#stock calculations
select 
s2.ing_name,
s2.ordered_weight,
ing.ing_weight*inv.quantity as total_inv_weight,
(ing.ing_weight*inv.quantity )-s2.ordered_weight as remaining_weight
 from
(SELECT
ing_id,
ing_name,
sum(ordered_weight) as ordered_weight
from stock1 
group by ing_name,ing_id) s2
left join inventory inv on s2.ing_id=inv.item_id
LEFT JOIN ingredient ing on ing.ing_id=s2.ing_id;

#Dashboard 3 staff
SELECT
cast(r.date as date),
s.first_name,
s.last_name,
s.hourly_rate,
cast(sh.start_time as time) as start_time,
cast(sh.end_time as time) as end_time,
truncate(hour(TIMEDIFF(sh.end_time,sh.start_time))+((minute(TIMEDIFF(sh.end_time,sh.start_time)))/60),1) as hours_in_shift,
round((hour(TIMEDIFF(sh.end_time,sh.start_time))+((minute(TIMEDIFF(sh.end_time,sh.start_time)))/60) ) * s.hourly_rate,2)as staff_cost
from rota r 
LEFT JOIN staff s on r.staff_id=s.staff_id
LEFT JOIN shift sh on r.shift_id=sh.shift_id;


