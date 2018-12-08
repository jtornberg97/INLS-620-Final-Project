library(ggplot2)
library(SPARQL)
library(dplyr)
library(ggalt)
library(scales)
theme_set(theme_classic())

# apache jena endpoint
endpoint <- "http://localhost:3030/MLB/query"

# namespace
prefix <- c ('MLB', '<http://localhost:3333/>',
             'foaf', '<http://xmlns.com/foaf/0.1/>',
             'rdfs','<http://www.w3.org/2000/01/rdf-schema#>',
             'rdf', '<http://www.w3.org/1999/02/22-rdf-syntax-ns#>',
             'xsd',' <http://www.w3.org/2001/XMLSchema#>')

# query 1: home runs by team in 1980

query1 <- "
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX MLB: <http://localhost:3333/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT ?TeamName ?HR ?yearID
WHERE {
?TeamSeason MLB:HomeRuns ?HR .
?TeamSeason MLB:TeamName ?TeamName .
?TeamSeason MLB:Year ?yearID .
FILTER(?yearID = 1980)
}
"

# save dataframe for query 1
qd <- SPARQL(endpoint,query1)
df <- qd$results

# delete year value from df
df <- df %>%
  select(TeamName, HR)


# query 2: home runs by team in 2000
query2 <- "
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX MLB: <http://localhost:3333/>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT ?TeamName ?HR ?yearID
WHERE {
?TeamSeason MLB:HomeRuns ?HR .
?TeamSeason MLB:TeamName ?TeamName .
?TeamSeason MLB:Year ?yearID .
FILTER(?yearID = 2000)
}
"

# save dataframe for query 2
qd1 <- SPARQL(endpoint,query2)
df1 <- qd1$results

# delete year value from df1
df1 <- df1 %>%
  select(TeamName, HR)
df1

# remove teams not yet created in 2000
df1 <- df1[-c(5,21,26,29),]

# ordering data frames alphabetically
df <- df[order(df$TeamName),]
df1 <- df1[order(df1$TeamName),]
  

# combining data frames

changed_df <- cbind(df, df1)

# renaming columns
names(changed_df) <- c("Team Name", "1980 HR", "x", "2000 HR")
changed_df

# removing second team name column
changed_df <- changed_df %>%
  select(`Team Name`, `1980 HR`, `2000 HR`)
changed_df

# make teams a factor for dumbell ordering
changed_df$`Team Name` <- factor(changed_df$`Team Name`, levels=as.character(changed_df$`Team Name`))

# adding column with difference between hr
changed_df %>% 
  mutate(diff = `2000 HR` - `1980 HR`) -> changed_df 

# making plot
gg <- ggplot(changed_df, aes(x=`1980 HR` , xend=`2000 HR`, y=`Team Name`, group=`Team Name`)) + 
  geom_dumbbell(color = "light blue", 
                colour_x = "darkred",
                colour_xend = "darkBlue",
                size_x = 2.5,
                size_xend = 2.5,
                show.legend = TRUE)+ 
  scale_x_continuous(name = waiver()) + 
  labs(x="Home Runs", 
       y="Team Name", 
       title="Home Runs Per Team 1980 vs 2000") +
  theme(plot.title = element_text(hjust=0.5, face="bold"),
        plot.background=element_rect(fill="#f7f7f7"),
        panel.background=element_rect(fill="#f7f7f7"),
        panel.grid.minor=element_blank(),
        panel.grid.major.y=element_blank(),
        panel.grid.major.x=element_line(),
        axis.ticks=element_blank(),
        legend.position="top",
        panel.border=element_blank()) +
  geom_text(aes(y = `Team Name`, label = diff),
            x = 260, hjust  = 1) +
  annotate(x = 260, y = "Region A", label = "Diff",
           geom = "text", vjust = 0,
           fontface = "bold",
           hjust = 1) -> gg
plot(gg)

