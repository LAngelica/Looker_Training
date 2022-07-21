# The name of this view in Looker is "Users"
view: users {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `thelook.users`
    ;;

#*************************************************************Dimension Examples (7)
  dimension: id {
    primary_key: yes
    hidden:  yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age + 2;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: complete_name {
    type: string
    sql: concat(${last_name}, ', ',${first_name}) ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: first_initial {
    type: string
    sql: substring(${first_name},1,1) ;;

  }

#*************************************************************Measure Examples
  measure: user_id {
    type: count
#    sql: ${id} ;;
  }

  measure: average_age {
    type: average
    label: "Average Age-Modified"
    description: "Average age has been modified."
    sql: ${age} ;;
  }

#*************************************************************
#*************************************************************
#*************************************************************
#*************************************************************
#*************************************************************
#*************************************************************
#*************************************************************
#*************************************************************

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  measure: latest_created {
    type: date
    sql: max(${created_raw}) ;;
  }


  measure: earliest_created {
    type: date
    sql: min(${created_raw}) ;;

  }









  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Age" in Explore.




  dimension: age_tier {
    type: tier
    tiers: [15,26,36,51,66]
    style: integer
    sql: ${age} ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.

  measure: total_age {
    type: sum
    sql: ${age} ;;
  }



  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.


  dimension_group: since_signup {
    type: duration
    sql_start: ${created_date} ;;
    sql_end: current_date() ;;
    intervals: [
      day,
      month
      ]
  }

  measure: average_days_since_signup {
    type: average
    sql: ${days_since_signup} ;;
  }


#this one doesn't work but average days does work....weird.
  measure: average_months_since_signup {
    type: average
    sql: ${months_since_signup} ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }



  dimension: dob {
    type: date
    sql: ${TABLE}.dob ;;
    required_access_grants: [user_dob_access]
  }




  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: country_name {
    type: string
    map_layer_name: countries
      sql: CASE WHEN ${country} = 'Brasil' THEN 'Brazil'
          ELSE ${country} END ;;
    }

  dimension: postal_code {
    type: string
    sql: ${TABLE}.postal_code ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: street_address {
    type: string
    sql: ${TABLE}.street_address ;;
  }



  measure: new_user_yesterday {
    type: count_distinct
    sql: ${id} ;;
    filters: [created_date: "yesterday"]
  }



  measure: new_users_yesterday {
    type: count
    filters: [created_date: "yesterday"]
  }
  measure: month_to_date_new_users {
    type: count
    filters: [created_date: "this month"]
  }
  measure: last_month_to_date_new_users {
    type: count
    filters: [created_date: "last month", created_date: "2 months ago for 1 month"]
    drill_fields: [id, created_date]
  }


}
