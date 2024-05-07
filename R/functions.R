# Pipeline functions
 
# Replace the contents of this file with your own pipeline functions and then
# update the pipeline in _targets.R.

# Imports ---------------------------------------------------------------------

# Package imports are included in this file for development and testing, but 
# should be commented out when the pipeline is run with tar_make. Every package 
# that is used within scripts in the R directory should be specified with 
# tar_options_set in _targets.R. This ensures the packages are loaded during a 
# pipeline run.

# library("dplyr")
# library("httr")
# library("jsonlite")
# library("janitor")
# library("lubridate")
# library("purrr")
# library("readr")
# library("stringr")

# Target functions ------------------------------------------------------------

fetch_products <- function() {
  
  # Set request parameters
  url <- "https://dummyjson.com/products?limit=10&select=id,title,brand,price"
  headers <- add_headers("Content-Type" = "application/json")
  
  # Send request
  tryCatch({
    response <- GET(
      url,
      headers,
      timeout = 60)},
    error = function(c) {
      stop(c)
    })
  
  # Get response text
  response_text <- content(
    response, 
    as = "text", 
    encoding = "utf-8")
  
  # Check the response
  if (response$status_code != 200) {
    stop(str_glue(
      "The server responded with the error message: {response_text}"))
  }  

  # Convert to a dataframe of results
  response_text |> 
    # Parse json text to list
    fromJSON(simplifyVector = FALSE) |> 
    # Get the data
    pluck("products") |> 
    # Convert list to dataframe
    bind_rows() |> 
    # Convert column names to snake case
    clean_names() |> 
    # Add a timestamp column to make runs unique
    mutate(created_at = format_ISO8601(Sys.time()))
}

split_products <- function(products) {
  
  # Split products data by brand
  brand_products <- group_split(products, brand)
  
  # Walk over the splits and save a dataframe of products for each brand
  brand_products_files <- map_chr(brand_products, function(brand_products, brand) {
    filepath <- file.path("dist", str_glue("{brand_products$brand[1]}.csv"))
    write_csv(brand_products, filepath)
    filepath
  })
  
  # Return the brand products
  brand_products_files
}