view: order_items_repurchase_facts {

  derived_table: {

#     sql_trigger_value: SELECT CURRENT_DATE() ;; --uncomment for persistence, but be careful of Templated Filter

    sql: SELECT ROW_NUMBER() OVER(ORDER BY ordered) as RN,*

            FROM

      ( SELECT
      order_items.user_id as user_id,
      order_items.id AS order_id,
      p.category as category,
      MIN(order_items.created_at) OVER(PARTITION BY order_items.user_id) as first_ordered_date,
      order_items.created_at as ordered,
      COUNT(order_items.id) OVER(partition by order_items.user_id) as lifetime_orders,
      ROW_NUMBER() OVER(PARTITION BY order_items.user_id ORDER BY order_items.created_at) as order_sequence_number,
      LEAD(order_items.created_at) OVER(partition by order_items.user_id ORDER BY order_items.created_at) as second_created_at,
      DATE_DIFF(CAST(order_items.created_at as date),CAST(LEAD(order_items.created_at) over(partition by order_items.user_id ORDER BY order_items.created_at) AS date), DAY) as repurchase_gap,
      DATE_DIFF(CURRENT_DATE,CAST(MIN(order_items.created_at) OVER(partition by order_items.user_id) as DATE), DAY) as days_since_first_order
      FROM  order_items
      JOIN inventory_items ii ON order_items.inventory_item_id=ii.id
      JOIN products p on ii.product_id = p.id
      WHERE {% condition product_category %} p.category {% endcondition %}
      GROUP BY 1,2,3,5
      )
      ;;

  }



  filter: product_category {

    suggest_dimension: category

  }

  dimension: category {sql:${TABLE}.category ;; type:string}



  dimension: row_number {

    primary_key: yes

    hidden: yes

    sql: ${TABLE}.RN ;;

  }

  measure: count {

    hidden:yes

    type: count

    drill_fields: [detail*]

  }

  dimension: user_id {

    hidden: yes

  }



  dimension: lifetime_orders {

    sql: ${TABLE}.lifetime_orders ;;

    hidden: yes

  }



  dimension_group: first_ordered_date {

    sql: ${TABLE}.first_ordered_date ;;

    type: time

    timeframes: [month,month_name,year]

  }

  dimension: lifetime_orders_tier {

    sql: ${lifetime_orders} ;;

    type: tier

    tiers: [1,2,3,4,5,6,7,8,9,10]

    style: integer

  }



  dimension: order_id {

#     primary_key: yes

    type: string

    sql: ${TABLE}.order_id ;;

  }



  dimension: ordered {

    hidden:yes

    type: string

    sql: ${TABLE}.ordered ;;

  }



  dimension: order_sequence_number {

    type: string

    sql: ${TABLE}.order_sequence_number ;;

  }



  dimension: second_created_at {

    hidden: yes

    type: string

    sql: ${TABLE}.second_created_at ;;

  }



  dimension: repurchase_gap {

    type: number

    sql: ${TABLE}.repurchase_gap ;;

  }



  dimension: repurchase_tier {

    type: tier

    tiers: [30,60,90,120,150,180]

    style: integer

    sql: ${repurchase_gap} ;;

  }



  dimension: days_since_first_order {

    type: number

    sql: ${TABLE}.days_since_first_order ;;

  }

  dimension: days_since_first_order_tier {

    type: tier

    tiers: [30,60,90,120,150,180]

    style: integer

    sql: ${days_since_first_order} ;;

  }



  dimension:  Returning_Customer{

    type: yesno

    sql: ${repurchase_gap} IS NOT NULL ;;

  }

  dimension: is_two {
    type: yesno
    hidden:  yes
    sql: ${order_sequence_number} = 2 ;;
  }


  measure: count_repurchases {

    description: "Count of unique users who have made more than 1 purchase"

    type: count_distinct

    drill_fields: [detail*]

    sql: ${user_id} ;;

    filters: {

      field: Returning_Customer

      value: "yes"

    }

    filters: {
      field: is_two
      value: "yes"

    }

  }



  ### Using an Average Distinct measure will get the average time it takes for a user to make a 2nd purchase

  ### and disregard duplicate users and subsequent orders

  measure: average_repurchase_gap {

    description: "The average time in days it takes for users to make a subsequent purchase"

    drill_fields: [detail*]

    type: average_distinct

    sql: ${repurchase_gap} ;;

    sql_distinct_key: ${order_id} ;;

    filters: {
      field: is_two
      value: "yes"

    }



  }



  ### These dimensions will check if a user's 2nd purchase was within certain time intervals

  dimension: repurchase_30  {type:yesno sql:${repurchase_gap} <=30 AND  ${order_sequence_number}=2;; hidden:yes}

  dimension: repurchase_60  {type:yesno sql:${repurchase_gap} <=60 AND  ${order_sequence_number}=2;; hidden:yes}

  dimension: repurchase_90  {type:yesno sql:${repurchase_gap} <=90 AND  ${order_sequence_number}=2;; hidden:yes}

  dimension: repurchase_120 {type:yesno sql:${repurchase_gap} <=120 AND ${order_sequence_number}=2;; hidden:yes}

  dimension: repurchase_150 {type:yesno sql:${repurchase_gap} <=150 AND ${order_sequence_number}=2;; hidden:yes}

  dimension: repurchase_180 {type:yesno sql:${repurchase_gap} <=180 AND ${order_sequence_number}=2;; hidden:yes}



  ### Count of repurchases by users in N days since first purchase

  measure: count_repurchases_first_30_days {

    label: "1m"

    group_label: "Count Repurchases"

    type: count_distinct

    sql: ${user_id} ;;

    drill_fields: [detail*]

    filters: {

      field: repurchase_30

      value: "yes"

    }

  }

  measure: count_repurchases_first_60_days {

    label: "2m"

    group_label: "Count Repurchases"

    type: count_distinct

    sql: ${user_id} ;;

    drill_fields: [detail*]

    filters: {

      field: repurchase_60

      value: "yes"

    }

  }

  measure: count_repurchases_first_90_days {

    label: "3m"

    group_label: "Count Repurchases"

    type: count_distinct

    sql: ${user_id} ;;

    drill_fields: [detail*]

    filters: {

      field: repurchase_90

      value: "yes"

    }

  }

  measure: count_repurchases_first_120_days {

    label: "4m"

    group_label: "Count Repurchases"

    type: count_distinct

    sql: ${user_id} ;;

    drill_fields: [detail*]

    filters: {

      field: repurchase_120

      value: "yes"

    }

  }

  measure: count_repurchases_first_150_days {

    label: "5m"

    group_label: "Count Repurchases"

    type: count_distinct

    sql: ${user_id} ;;

    drill_fields: [detail*]

    filters: {

      field: repurchase_150

      value: "yes"

    }

  }

  measure: count_repurchases_first_180_days {

    label: "6m"

    group_label: "Count Repurchases"

    type: count_distinct

    sql: ${user_id} ;;

    drill_fields: [detail*]

    filters: {

      field: repurchase_180

      value: "yes"

    }

  }

  #### Repurchase rates



  measure: repurchase_rate {

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_30 {

    label: "1m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_30_days}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_60 {

    label: "2m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_60_days}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_90 {

    label: "3m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_90_days}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_120 {

    label: "4m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_120_days}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_150 {

    label: "5m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_150_days}/nullif(${count_customers},0) ;;

  }

  measure: repurchase_rate_180 {

    label: "6m"

    group_label: "Repurchase Rates"

    type: number

    drill_fields: [detail*]

    value_format_name: percent_1

    sql: 1.0*${count_repurchases_first_180_days}/nullif(${count_customers},0) ;;

  }

  measure: count_customers {

    drill_fields: [detail*]

    type: count_distinct

    sql: ${user_id} ;;

  }

  measure: count_orders {

    drill_fields: [detail*]

    type: count_distinct

    sql: ${order_id} ;;

  }

  measure: percent_of_customers {

    drill_fields: [detail*]

    type: percent_of_total

    sql: ${count_customers} ;;

  }

  set: detail {

    fields: [

      user_id,

      order_id,

      ordered,

      order_sequence_number,

      lifetime_orders,

      first_ordered_date_month

    ]

  }

}
