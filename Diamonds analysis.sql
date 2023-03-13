SELECT * FROM diamond_prices;

/*1 How many total diamonds are on the list?*/
SELECT COUNT(carat) AS total_diamonds
 FROM diamond_prices;
 
/*2 Rank the diamonds based on its carat.*/
SELECT carat, rank() over(ORDER BY carat DESC) AS rnk
 FROM diamond_prices
 GROUP BY carat;
 
/*3 Determine the carat with highest no. of diamonds.*/
SELECT carat, COUNT(carat) AS no_per_carat, rank() over(ORDER BY carat DESC) AS rnk
 FROM diamond_prices
 GROUP BY carat
 ORDER BY no_per_carat DESC
 LIMIT 10;
 
/*4 Determine the carat with lowest no. of diamonds.*/
SELECT carat, COUNT(carat) AS no_per_carat, rank() over(ORDER BY carat DESC) AS rnk
 FROM diamond_prices
 GROUP BY carat
 ORDER BY no_per_carat ASC
 LIMIT 10;
 
/*5 Determine the no. of diamonds per cut.*/
SELECT cut, COUNT(cut) AS no_per_cut
 FROM diamond_prices
 GROUP BY cut
 ORDER BY no_per_cut DESC;
 
/*6 Determine the no. of diamonds per color.*/
SELECT color, COUNT(color) AS no_per_color
 FROM diamond_prices
 GROUP BY color
 ORDER BY no_per_color DESC;
 
 /*7 Determine the no. of diamonds per clarity.*/
SELECT clarity, COUNT(clarity) AS no_per_clarity
 FROM diamond_prices
 GROUP BY clarity
 ORDER BY no_per_clarity DESC;
 
  /*8 Determine the no. of diamonds per depth.*/
SELECT depth, COUNT(depth) AS no_per_depth
 FROM diamond_prices
 GROUP BY depth
 ORDER BY no_per_depth DESC;
 
   /*9 Determine the no. of diamonds per table.*/
SELECT table_dia, COUNT table_dia) AS no_per_table
 FROM diamond_prices
 GROUP BY table_dia
 ORDER BY no_per_table DESC;
 
    /*10 What is the 3 most expensive diamonds.*/
SELECT *, rank() over(ORDER BY price DESC) AS rnk
 FROM diamond_prices
 ORDER BY rnk
 LIMIT 3;
 
     /*11 What is the 3 least expensive diamonds.*/
SELECT *, row_number() over(ORDER BY price) AS rnk
 FROM diamond_prices
 ORDER BY rnk
 LIMIT 3;
 
     /*12 What is the price of most expensive diamond per carat.*/
SELECT *, rank() over(ORDER BY carat DESC) AS rnk_carat
FROM (SELECT carat, price AS highest_price, row_number() over(partition BY carat ORDER BY price DESC) AS rnk_price
 FROM diamond_prices
 ORDER BY rnk_price)x
WHERE  rnk_price = 1
ORDER BY highest_price;
 


    