view: user_order_facts {
  derived_table: {
    explore_source: order_items {
      column: user_id {
        field: order_items.user_id
      }
      column: lifetime_number_of_orders {
        field: order_items.order_count
      }
      column: lifetime_customer_value {
        field: order_items.total_revenue
      }
      column: total_sale_price {
        field: order_items.total_sale_price
      }
    }
  }
  # Define the view's fields as desired
  dimension: user_id {
  type: string
  }

  dimension: lifetime_number_of_orders {
    type: number
  }

  dimension: lifetime_customer_value {
    type: number
  }

  dimension: lifetime_orders_bucketed {
    type: tier
    style: integer
    tiers: [2,4,6]
    sql: ${lifetime_number_of_orders} ;;
  }


  measure: user_cnt {
    label: "User count"
    type: count_distinct
    sql: ${user_id} ;;
  }
}
