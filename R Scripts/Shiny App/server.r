library(ggplot2)
library(SPARQL)
library(dplyr)
library(ggalt)
library(scales)
library(shiny)

# apache jena endpoint
endpoint <- "http://localhost:3030/MLB/query"

# namespace
prefix <- c ('MLB', '<http://localhost:3333/>',
             'foaf', '<http://xmlns.com/foaf/0.1/>',
             'rdfs','<http://www.w3.org/2000/01/rdf-schema#>',
             'rdf', '<http://www.w3.org/1999/02/22-rdf-syntax-ns#>',
             'xsd',' <http://www.w3.org/2001/XMLSchema#>')

# query 1: home runs per season for the chicago cubs
query1 <-
  "
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX MLB: <http://localhost:3333/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
SELECT ?TeamName ?HR ?ERA ?yearID 
    WHERE {
?TeamSeason MLB:HomeRuns ?HR .
?TeamSeason MLB:EarnedRunAverage ?ERA .
?TeamSeason MLB:TeamName ?TeamName .
FILTER (?TeamName = 'Chicago Cubs')
?TeamSeason MLB:Year ?yearID .
}"

# save dataframe for query 1
qd <- SPARQL(endpoint,query1)
df <- qd$results
df
# delete team name from df
df <- df %>%
  select(yearID, HR, ERA)

# ordering by year
df <- df[order(df$yearID),]

# define input and output function
function(input, output) {
  
# Step 3 Set it up for the check boxes for source sectors
data_1=reactive({
  return(df[CO2data$sector%in%input$source_choose,])
})