USE dannys_diner;

-- 1. Total amount spent by each customer
SELECT s.customer_id, SUM(m.price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 2. Number of unique days each customer visited the diner
SELECT customer_id, COUNT(DISTINCT order_date) AS visit_days
FROM sales
GROUP BY customer_id;

-- 3. First item purchased by each customer
WITH first_purchase AS (
  SELECT customer_id, MIN(order_date) AS first_order_date
  FROM sales
  GROUP BY customer_id
)
SELECT fp.customer_id, m.product_name
FROM first_purchase fp
JOIN sales s ON fp.customer_id = s.customer_id AND fp.first_order_date = s.order_date
JOIN menu m ON s.product_id = m.product_id;

-- 4. Most purchased item by all customers
SELECT m.product_name, COUNT(*) AS purchase_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchase_count DESC
LIMIT 1;

-- 5. Most popular item per customer
SELECT s.customer_id, m.product_name, COUNT(*) AS purchase_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
ORDER BY s.customer_id, purchase_count DESC;

-- 6. First item purchased by the customer after they became a member
WITH member_purchases AS (
  SELECT s.customer_id, s.order_date, m.product_name, mem.join_date
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  JOIN members mem ON s.customer_id = mem.customer_id
  WHERE s.order_date >= mem.join_date
)
SELECT customer_id, MIN(order_date) AS first_order_after_join, product_name
FROM member_purchases
GROUP BY customer_id;

-- 7. Item purchased just before the customer became a member
WITH pre_member_purchases AS (
  SELECT s.customer_id, s.order_date, m.product_name, mem.join_date
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  JOIN members mem ON s.customer_id = mem.customer_id
  WHERE s.order_date < mem.join_date
)
SELECT customer_id, MAX(order_date) AS last_order_before_join, product_name
FROM pre_member_purchases
GROUP BY customer_id;

-- 8. Total items and amount spent for each member before they became a member
SELECT s.customer_id, COUNT(s.product_id) AS total_items, SUM(m.price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;

-- 9. Points calculation: $1 spent = 10 points; sushi has 2x points multiplier
WITH points_calculation AS (
  SELECT s.customer_id, m.product_name, m.price,
    CASE
      WHEN m.product_name = 'sushi' THEN m.price * 20
      ELSE m.price * 10
    END AS points_earned
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
)
SELECT customer_id, SUM(points_earned) AS total_points
FROM points_calculation
GROUP BY customer_id;

-- 10. Points calculation with 2x multiplier in the first week after joining (including join date)
WITH points_week_bonus AS (
  SELECT s.customer_id, m.product_name, s.order_date, m.price, mem.join_date,
    CASE
      -- Double points in the first week after joining for all items
      WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) THEN m.price * 20
      -- Double points for sushi outside the bonus week
      WHEN m.product_name = 'sushi' THEN m.price * 20
      ELSE m.price * 10
    END AS points_earned
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  JOIN members mem ON s.customer_id = mem.customer_id
)
SELECT customer_id, SUM(points_earned) AS total_points
FROM points_week_bonus
GROUP BY customer_id;

-- 11. Points earned by customer A and B by the end of January
WITH january_points AS (
  SELECT s.customer_id, m.product_name, s.order_date, m.price, mem.join_date,
    CASE
      -- Double points in the first week after joining for all items
      WHEN s.order_date BETWEEN mem.join_date AND DATE_ADD(mem.join_date, INTERVAL 6 DAY) THEN m.price * 20
      -- Double points for sushi outside the bonus week
      WHEN m.product_name = 'sushi' THEN m.price * 20
      ELSE m.price * 10
    END AS points_earned
  FROM sales s
  JOIN menu m ON s.product_id = m.product_id
  JOIN members mem ON s.customer_id = mem.customer_id
  WHERE s.order_date <= '2021-01-31' AND s.customer_id IN ('A', 'B')
)
SELECT customer_id, SUM(points_earned) AS total_points
FROM january_points
GROUP BY customer_id;
