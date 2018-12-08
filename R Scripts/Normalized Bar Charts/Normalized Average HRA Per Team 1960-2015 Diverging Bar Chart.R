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

SELECT ?TeamSeason ?TeamName ?HRA ?yearID
WHERE {
?TeamSeason MLB:HomeRunsAllowed ?HRA .
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
df <- aggregate(df$HRA, by=list(TeamName=df$TeamName), FUN=mean)
colnames(df)[2] <- "avg_hra"

# data prep
df$hra_z <- round((df$avg_hra - mean(df$avg_hra))/sd(df$avg_hra), 2)  # compute normalized mpg
df$hra_type <- ifelse(df$hra_z < 0, "Below", "Above")  # above / below avg flag
df <- df[order(df$hra_z), ]  # sort
df$`TeamName` <- factor(df$`TeamName`, levels = df$`TeamName`)  # convert to factor to retain sorted order in plot.

ggplot(df, aes(x=`TeamName`, y=hra_z, label=hra_z)) + 
  geom_point(stat='identity', aes(col=hra_type), size=6)  +
  scale_color_manual(name="Average Home Runs Allowed", 
                    labels = c("Above Average", "Below Average"), 
                    values = c("Above"="Red", "Below"="Green")) + 
  geom_text(color="black", size=2) +
  labs(subtitle="Normalized Average Home Runs Allowed For MLB Teams 1960-2015", 
       title= "Diverging Bars", x="Team Name", y='Z-Score') + 
  coord_flip()

