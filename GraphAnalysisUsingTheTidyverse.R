# https://www.r-bloggers.com/graph-analysis-using-the-tidyverse/
library(readr)
setwd('/Users/fsmoura/Documents/R-files/')
small_trains <- read.csv('small_trains.csv', header =  TRUE, sep = ",")
names(small_trains)
head(small_trains)
library(dplyr)
routes <- small_trains %>%
  group_by(departure_station, arrival_station) %>%
  summarise(journey_time = mean(journey_time_avg)) %>%
  ungroup() %>%
  mutate(from = departure_station,
         to = arrival_station) %>%
  select(from, to, journey_time)

routes
library(tidygraph)
graph_routes <- as_tbl_graph(routes)
graph_routes

library(stringr)
graph_routes <- graph_routes %>%
  activate(nodes) %>%
  mutate(
    title = str_to_title(name),
    label = str_replace_all(title, " ", "\n")
  )

graph_routes


stations <- graph_routes %>%
  activate(nodes) %>%
  pull(title)

stations



library(ggplot2)
thm <- theme_minimal() +
  theme(
    legend.position = "none",
    axis.title = element_blank(),
    axis.text = element_blank(),
    panel.grid = element_blank(),
    panel.grid.major = element_blank(),
  )
theme_set(thm)



library(ggraph)
graph_routes %>%
  ggraph(layout = "kk") +
  geom_node_point() +
  geom_edge_diagonal()


graph_routes %>%
  ggraph(layout = "kk") +
  geom_node_text(aes(label = label, color = name), size = 3) +
  geom_edge_diagonal(color = "gray", alpha = 0.4)


from <- which(stations == "Arras")
to <-  which(stations == "Nancy")

shortest <- graph_routes %>%
  morph(to_shortest_path, from, to, weights = journey_time)

shortest


shortest %>%
  mutate(selected_node = TRUE) %>%
  unmorph()



shortest <- shortest %>%
  mutate(selected_node = TRUE) %>%
  activate(edges) %>%
  mutate(selected_edge = TRUE) %>%
  unmorph()


shortest <- shortest %>%
  activate(nodes) %>%
  mutate(selected_node = ifelse(is.na(selected_node), 1, 2)) %>%
  activate(edges) %>%
  mutate(selected_edge = ifelse(is.na(selected_edge), 1, 2)) %>%
  arrange(selected_edge)

shortest



shortest %>%
  ggraph(layout = "kk") +
  geom_edge_diagonal(aes(alpha = selected_edge), color = "gray") +
  geom_node_text(aes(label = label, color =name, alpha = selected_node ), size = 3)




shortest %>%
  activate(edges) %>%
  filter(selected_edge == 2) %>%
  as_tibble() %>%
  summarise(
    total_stops = n() - 1,
    total_time = round(sum(journey_time) / 60)
  )


from <- which(stations == "Montpellier")
to <-  which(stations == "Laval")

shortest <- graph_routes %>%
  morph(to_shortest_path, from, to, weights = journey_time) %>%
  mutate(selected_node = TRUE) %>%
  activate(edges) %>%
  mutate(selected_edge = TRUE) %>%
  unmorph() %>%
  activate(nodes) %>%
  mutate(selected_node = ifelse(is.na(selected_node), 1, 2)) %>%
  activate(edges) %>%
  mutate(selected_edge = ifelse(is.na(selected_edge), 1, 2)) %>%
  arrange(selected_edge)

shortest %>%
  ggraph(layout = "kk") +
  geom_edge_diagonal(aes(alpha = selected_edge), color = "gray") +
  geom_node_text(aes(label = label, color =name, alpha = selected_node ), size = 3)

