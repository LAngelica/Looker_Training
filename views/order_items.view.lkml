# The name of this view in Looker is "Order Items"
view: order_items {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `thelook.order_items`
    ;;
  drill_fields: [id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      day_of_week,
      date,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      day_of_week,
      date,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}.delivered_at ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Inventory Item ID" in Explore.

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      day_of_week, # Angelica added
      date,
      week,
      month,
      month_name, # Angelica added
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${inventory_items.product_retail_price} ;;
  }


  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_sale_price {
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
  }

  measure: total_sale_price_running {
    description: "Cumulative total sales from items sold (also known as a running total)"
    type: running_total
    value_format_name: usd
    sql:  ${total_sale_price} ;;
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name:  usd
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      day_of_week,
      date,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: user_gender {
    type: string
    sql: ${users.gender} ;;
  }

  #*****************************************************************************************************ANGELICA ADDED
  #This is pulling from a field from within the table and I don't think that is considered good practice
  dimension: return_indicator {
    type: yesno
    sql:  ${TABLE}.returned_at is not null ;;
  }

  measure: order_id_cnt {
    type: count_distinct
    sql: ${order_id};;
  }

  measure: order_id_cnt_yesterday {
    type: count_distinct
    sql: ${order_id};;
    filters: [created_date: "yesterday"]
  }




  measure: number_of_items_returned {
    description: "Number of items that were returned by dissatisfied customers"
    type:  count_distinct # I got a message that count does not work here....err why not? the message says "Measures" of type count do not use the sql parameter
    sql: ${inventory_item_id} ;; #will this correctly count the same product twice if it was ordered twice?
    filters: [return_indicator: "yes"]
  }

  measure: number_of_items_sold {
    description: "Number of items that were bought"
    type: count_distinct
    sql: ${inventory_item_id} ;;
    #this is very much like number_of_items_returned but we want to see all items, not just the ones returned
  }

  measure: item_return_rate {
    type:  number #percent_of_total?
    sql: ${number_of_items_returned} / ${number_of_items_sold};;
  }

  measure: users_with_returns {
    description: "Number of Customer Returning Items"
    type:  count_distinct
    sql:  ${user_id} ;;
    filters: [return_indicator: "yes"]
  }

  measure: users_who_purchased {
    description: "Number of users who made a purchase"
    type: count_distinct
    sql: ${user_id} ;;
  }

  measure: percent_of_users_return {
    description: "Number of Customer Returning Items / total number of customers"
    type: number
    sql:  ${users_with_returns}/${users_who_purchased};;
  }

  measure: average_spend_per_customer {
    description: "Total Sale Price / total number of customers "
    type: number
    value_format_name: usd
    sql:  ${total_sale_price}/${users_who_purchased};;
    drill_fields: [demographic_detail*]
  }

#Total Gross Revenue: Total revenue from completed sales (cancelled and returned orders excluded)
measure: total_gross_revenue {
  description: "Total revenue from completed sales (cancelled and returned orders excluded)"
  type: sum
  value_format_name: usd
  sql:  ${sale_price} ;;
  filters: [return_indicator: "no", delivered_date: "-NULL"]
  drill_fields: [detail2*]
  # don't see a column for canceled.
  # Maybe it's ordered and then not delivered and also not returned?
  # so how to do: return_ind = no OR return_ind = no and delivered_date is not null
  # is this right?  How would I check this?
}




  measure: total_gross_revenue_yesterday {
    description: "Total revenue from completed sales (cancelled and returned orders excluded)"
    label: "Gross Revenue- yesterday"
    type: sum
    value_format_name: usd
    sql:  ${sale_price} ;;
    filters: [return_indicator: "no", delivered_date: "-NULL", delivered_date: "yesterday"]
  }


# do these look correct? (average cost and total cost)...total cost is then pulled into average_gross_margin

# measure: total_cost {
#     description: "Total cost of items sold from inventory "
#     type:  sum
#     value_format_name: usd
#     sql: ${inventory_items.cost} ;;
#   }

# measure: average_cost {
#     description: "Average cost of items sold from inventory"
#     type: average
#     value_format_name: usd
#     sql: ${inventory_items.cost} ;;
#   }

# this did not result in a nested error
 measure: total_gross_margin_amount {
   description: "Total difference between the total revenue from completed sales and the cost of the goods that were sold "
   type: sum
   value_format_name: usd
   sql: ${sale_price} - ${inventory_items.cost} ;; # is this correct? - ${inventory_items.cost}
   drill_fields: [detail2*]
 }

  measure: total_gross_margin_amount_demographic {
    description: "Total difference between the total revenue from completed sales and the cost of the goods that were sold "
    type: sum
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost} ;; # is this correct? - ${inventory_items.cost}
    drill_fields: [demographic_detail*]
    # knowledge
    # link: {
    #   label: "Test label"
    #   url: "https://new explore to link to" #using liquid you can add filters

    # }
  }

measure: percent_of_total_gross_margin {
  label: "% of Total Gross Margin"
  type: percent_of_total
  sql:  ${total_gross_margin_amount_demographic} ;;
  direction: "column"
}

 measure: gross_margin_percent {
   description: "Total Gross Margin Amount / Total Gross Revenue "
   type: number
  value_format_name: percent_1
   sql:  ${total_gross_margin_amount}/${total_gross_revenue};;
 }


# measure: average_gross_margin {
#   description: "Average difference between the total revenue from completed sales and the cost of the goods that were sold"
#   type: average
#   sql: ${total_gross_revenue} -${inventory_items.cost} ;;
# }

  #*****************************************************************************************************

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.last_name,
      users.id,
      users.first_name,
      inventory_items.id,
      inventory_items.product_name,
      products.name,
      products.id
    ]
  }


  set:  detail2 {
    fields: [
      products.brand,
      products.category,
      total_gross_revenue
    ]
    }

  set: demographic_detail {
    fields: [
      users.country,
      users.gender,
      users.age_tier,
      total_gross_revenue,
      average_spend_per_customer
      ]
  }

}
