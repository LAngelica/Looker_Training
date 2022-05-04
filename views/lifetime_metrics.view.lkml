
view: lifetime_metrics {
  derived_table: { # to me this is exactly like a CTE
    sql:
      SELECT
        user_id
      , SUM(sale_price) AS total_spent
      , count(distinct order_id) as total_orders
      , min(created_at) as first_order
      , max(created_at) as last_order
      FROM order_items
      GROUP BY 1;;
  }
  dimension: customer_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: lifetime_spend {
    type: number
    value_format: "0.00"
    sql: ${TABLE}.total_spent ;;
  }

  dimension: lifetime_orders {
    type: number
    sql: ${TABLE}.total_orders  ;;
  }

  dimension: lifetime_orders_bucketed {
    type: tier
    style: integer
    tiers: [0,1,2,3,6,10]
    sql: ${lifetime_orders};;
  }

  measure: customer_count {
    type: count_distinct
    sql: ${customer_id} ;;
  }

  dimension: lifetime_spend_bucketed {
    type: tier
    style: integer
    tiers: [5,20,50,100,500,1000]
    sql: ${lifetime_spend} ;;
    value_format_name: usd
  }

  dimension: first_order {
    type: date
    sql: ${TABLE}.first_order ;;
  }

  dimension: last_order {
    type: date
    sql: ${TABLE}.last_order ;;
  }

  dimension: days_since_last_order {
    type: duration_day
    sql_start: ${last_order} ;;
    sql_end: current_date();;
  }

  dimension: is_active {
    type: yesno
    sql: ${days_since_last_order} <= 90;;
  }

  measure: avg_days_since_last_order {
    type: average
    sql: ${days_since_last_order} ;;
  }

  dimension: is_repeat_customer {
    type: yesno
    sql: ${lifetime_orders} > 1 ;;
  }

  measure: avg_lifetime_spend {
    type: average
    description: "The average lifetime spend; aka the average lifetime revenue"
    sql: ${lifetime_spend} ;;
  }

  measure: avg_lifetime_orders {
    type: average
    description: "The average number of orders a customer makes over their lifetime thus far"
    sql: ${lifetime_orders} ;;
  }


}
