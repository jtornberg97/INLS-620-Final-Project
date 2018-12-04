library(ggplot2)
library(SPARQL)
library(dplyr)
library(ggalt)
library(scales)

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
  
  SELECT ?TeamName ?HR ?yearID
      WHERE {
  ?TeamSeason MLB:HomeRuns ?HR .
  ?TeamSeason MLB:TeamName ?TeamName .
  FILTER (?TeamName = 'Chicago Cubs')
  ?TeamSeason MLB:Year ?yearID .
  FILTER (?yearID > 1989 && ?yearID < 2001) .
}"

# save dataframe for query 1
qd <- SPARQL(endpoint,query1)
df <- qd$results
df
# delete year value from df
df <- df %>%
  select(yearID, HR)

# ordering by year
df <- df[order(df$yearID),]

# plot
gg <- ggplot(df, aes(x=factor(yearID), y=HR)) + 
  geom_bar( stat="identity", width=.5, fill="tomato3") + 
  geom_text(aes(label = HR), vjust=-.)+
  labs(title="Ordered Bar Chart", 
       subtitle="Make Vs Avg. Mileage", 
       caption="source: mpg") + 
  theme(axis.text.x = element_text(angle=65, vjust=0.6)) +
  coord_flip()
plot(gg)

