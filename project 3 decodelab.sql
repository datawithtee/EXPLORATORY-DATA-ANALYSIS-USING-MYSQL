-- Data Exploration --

SELECT * FROM shipping_db.`sales.dataset`;

-- total order --
SELECT count(OrderID)
FROM shipping_db.`sales.dataset`;

-- total revenue --
SELECT round(sum(TotalPrice), 2)
FROM shipping_db.`sales.dataset`;

-- customer count --
SELECT count(distinct customerID)
FROM shipping_db.`sales.dataset`;

-- total quantity sold --
SELECT SUM(Quantity) AS total_quantity
FROM shipping_db.`sales.dataset`;

-- Avg sales --
SELECT round(sum(TotalPrice)/count(OrderID),2)
FROM shipping_db.`sales.dataset`;

-- order status --
SELECT orderstatus, count(OrderID) as totalOrder
FROM shipping_db.`sales.dataset`
group by orderstatus
order by count(OrderID) desc;

-- distinct product count --
SELECT product, count(OrderID) as totalproduct
FROM shipping_db.`sales.dataset`
group by product
order by count(OrderID) desc;

-- REFERRAL --
SELECT ReferralSource, COUNT(OrderID)
FROM shipping_db.`sales.dataset`
group by ReferralSource
order by count(OrderID) desc;

-- COUPON --
SELECT CouponCode2, COUNT(OrderID)
FROM shipping_db.`sales.dataset`
group by CouponCode2
order by count(OrderID) desc;

-- payment method use --

-- payment method --
SELECT PaymentMethod, count(orderID) as total_payment
FROM shipping_db.`sales.dataset`
GROUP BY PaymentMethod
order by count(orderID) desc;

-- PRODUCT BY ORDER STATUS --
SELECT product, orderstatus, count(OrderID) as totalOrder,
Row_number() over (partition by product order by count(OrderID) desc) 
FROM shipping_db.`sales.dataset`
group by product, orderstatus;

-- PRODUCT WITH HIGHEST CANCELLED RATE --

Select product, orderStatus, round(sum(TotalPrice),2) as productSales, count(orderID) as totalOrder
FROM shipping_db.`sales.dataset`
where orderStatus = "Cancelled"
group by product, orderStatus
order by totalOrder desc;

WITH product_stats AS (
  SELECT 
    product,
    COUNT(OrderID) AS totalOrders,
    SUM(CASE WHEN orderstatus = 'Cancelled' THEN 1 ELSE 0 END) AS cancelledOrders,
    ROUND(
      SUM(CASE WHEN orderstatus = 'Cancelled' THEN 1 ELSE 0 END) / NULLIF(COUNT(OrderID), 0) * 100, 
      2
    ) AS cancelledRatePercent
  FROM shipping_db.`sales.dataset`
  GROUP BY product
)
SELECT 
  product,
  totalOrders,
  cancelledOrders,
  cancelledRatePercent,
  ROW_NUMBER() OVER (ORDER BY cancelledRatePercent DESC) AS rn
FROM product_stats
ORDER BY cancelledRatePercent DESC;

-- product with the highest returned rate --
WITH product_stats AS (
  SELECT 
    product,
    COUNT(OrderID) AS totalOrders,
    SUM(CASE WHEN orderstatus = 'returned' THEN 1 ELSE 0 END) AS returnedOrders,
    ROUND(
      SUM(CASE WHEN orderstatus = 'returned' THEN 1 ELSE 0 END) / NULLIF(COUNT(OrderID), 0) * 100, 
      2
    ) AS returnedRatePercent
  FROM shipping_db.`sales.dataset`
  GROUP BY product
)
SELECT 
  product,
  totalOrders,
  returnedOrders,
  returnedRatePercent,
  ROW_NUMBER() OVER (ORDER BY returnedRatePercent DESC) AS rn
FROM product_stats
ORDER BY returnedRatePercent DESC;

SELECT product, paymentMethod, orderstatus, count(OrderID) as totalOrder,
Row_number() over (partition by product, OrderStatus order by count(OrderID) desc) as row_numb
FROM shipping_db.`sales.dataset`
group by product, paymentMethod, orderstatus;

-- top selling product--
SELECT
    Product,
    ROUND(SUM(TotalPrice), 2) AS revenue
FROM shipping_db.`sales.dataset`
GROUP BY Product
ORDER BY revenue DESC;

SELECT
    DATE_FORMAT(Date, 'yyyy') AS month,
    ROUND(SUM(TotalPrice), 2) AS total_sales
FROM shipping_db.`sales.dataset`
GROUP BY month
ORDER BY month;

-- top 10 customers --
SELECT
    CustomerID,
    ROUND(SUM(TotalPrice), 2) AS total_spent
FROM shipping_db.`sales.dataset`
GROUP BY CustomerID
ORDER BY total_spent DESC
LIMIT 10;
