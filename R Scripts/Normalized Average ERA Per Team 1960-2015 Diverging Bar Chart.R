library(SPARQL)
library(ggplot2)
library(dplyr)

# apache jena endpoint
endpoint <- "http://localhost:3030/MLB/query"

# namespace
prefix <- c ('MLB', '<http://localhost:3333/>',
             'foaf', '<http://xmlns.com/foaf/0.1/>',
             'rdfs','<http://www.w3.org/2000/01/rdf-schema#>',
             'rdf', '<http://www.w3.org/1999/02/22-rdf-syntax-ns#>',
             'xsd',' <http://www.w3.org/2001/XMLSchema#>')

# query 1: home runs allowed by teams since 1960
query1 <- "
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX MLB: <http://localhost:3333/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT ?TeamSeason ?TeamName ?ERA ?yearID
WHERE {
?TeamSeason MLB:EarnedRunAverage ?ERA .
?TeamSeason MLB:TeamName ?TeamName .
?TeamSeason MLB:Year ?yearID .
FILTER (?yearID > 1960).
}
"
# save dataframe
qd <- SPARQL(endpoint,query1)
df <- qd$results

# average per team
df <- group_by(df, TeamName)
df <- aggregate(df$ERA, by=list(TeamName=df$TeamName), FUN=mean)
colnames(df)[2] <- "avg_era"

# data prep
df$era_z <- round((df$avg_era - mean(df$avg_era))/sd(df$avg_era), 2)  # compute normalized mpg
df$era_type <- ifelse(df$era_z < 0, "Below", "Above")  # above / below avg flag
df <- df[order(df$era_z), ]  # sort
df$`TeamName` <- factor(df$`TeamName`, levels = df$`TeamName`)  # convert to factor to retain sorted order in plot.

ggplot(df, aes(x=`TeamName`, y=era_z, label=era_z)) + 
  geom_point(stat='identity', aes(col=era_type), size=6)  +
  scale_color_manual(name="Average ERA", 
                     labels = c("Above Average", "Below Average"), 
                     values = c("Above"="Red", "Below"="Green")) + 
  geom_text(color="black", size=2) +
  labs(subtitle="Normalized ERA For MLB Teams 1960-2015", 
       title= "Diverging Bars", x="Team Name", y='Z-Score') + 
  coord_flip()

