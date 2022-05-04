view: order_sequence {

  derived_table: { # to me this is exactly like a CTE
    sql:
      SELECT distinct
        user_id
      , order_id
      , date(created_at) as created_at
      , row_number() over(partition by user_id order by created_at) as order_sequence
      FROM order_items
      GROUP BY 1,2,3;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }


  dimension: order_sequence {
    type: number
    sql: ${TABLE}.order_sequence ;;
  }

  dimension: created_at {
    type: date
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: since_last_order {
    type: duration
    sql_start: ${created_at} ;;
    sql_end: current_date() ;;
    intervals: [
      day,
      month
    ]
  }




}
