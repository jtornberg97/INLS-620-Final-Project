library(SPARQL)
library(ggplot2)

# apache jena endpoint
endpoint <- "http://localhost:3030/MLB/query"

# namespace
prefix <- c ('MLB', '<http://localhost:3333/>',
             'foaf', '<http://xmlns.com/foaf/0.1/>',
             'rdfs','<http://www.w3.org/2000/01/rdf-schema#>',
             'rdf', '<http://www.w3.org/1999/02/22-rdf-syntax-ns#>',
             'xsd',' <http://www.w3.org/2001/XMLSchema#>')

# query 1: average home runs by season from 2000 on
query1 <- "
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX MLB: <http://localhost:3333/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT ?TeamSeason ?HR ?yearID
WHERE {
?TeamSeason MLB:HomeRuns ?HR .
?TeamSeason MLB:Year ?yearID .
  FILTER ((?yearID > 1900) && (?yearID < 2016))
}
"

# save dataframe
qd <- SPARQL(endpoint,query1)
df <- qd$results

# group by home runs per season
df <- aggregate(df$HR, by=list(yearID=df$yearID), FUN=sum)
colnames(df)[2] <- "HR"

# making density plots
p8 <- ggplot(df, aes(x = HR)) +
  geom_density()+
  labs(x = "Total Home Runs Per Year", y = "Density", title = "Density of Total Home Runs Per Year in the MLB", 
       subtitle = "1900 - 2015") +
p8

