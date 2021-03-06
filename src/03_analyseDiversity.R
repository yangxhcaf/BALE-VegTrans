# https://jonlefcheck.net/2012/10/24/nmds-tutorial-in-r/
# Load environment variables and libraries
source("C:/Users/tnauss/permanent/plygrnd/mekbib_vegtrans/BALE-VegTrans/src/00_set_environment.R")


#### Read vegetation matrix
vegdat = readRDS(paste0(path_rdata, "/vegdat.rds"))
vegdat_mtrx = readRDS(paste0(path_rdata, "/vegdat_mtrx.rds"))
vegdat_mtrx_pres_abs = readRDS(paste0(path_rdata, "/vegdat_mtrx_pres_abs.rds"))
vegdat_div = readRDS(paste0(path_rdata, "/vegdat_div.rds"))
vegdat_div_long = readRDS(paste0(path_rdata, "/vegdat_div_long.rds"))
vegdat_div_distsum = readRDS(paste0(path_rdata, "/vegdat_div_distsum.rds"))
nmds = readRDS(paste0(path_rdata, "/nmds.rds"))
bp_nmds = readRDS(paste0(path_rdata, "/bp_nmds.rds"))



#### Linear mixed-effect modelling
# vegdat_div$Distance = as.numeric(as.character(vegdat_div$Distance))
# vegdat_div$Settlement = as.factor(vegdat_div$Settlement)
lmer_shannon = lmer(formula  = Shannon ~ Distance + (1 | PlotID), data = vegdat_div)
display(lmer_shannon)
summary(lmer_shannon)

lmer_shannon = lmer(formula  = Shannon ~ Distance + (1 + Distance | Distance), data = vegdat_div)
display(lmer_shannon)
summary(lmer_shannon)


#### CCA

vegdat_div$Distance = as.numeric(as.character(vegdat_div$Distance))
vegdat_cca = cca(vegdat_mtrx_pres_abs ~ Distance + Alt, data=vegdat_div, na.action = na.omit)

anova.cca(vegdat_cca)
# anova.cca(vegdat_cca, by="terms")
# anova.cca(vegdat_cca, by="axis")

plot(vegdat_cca, display=c("species"))
plot(vegdat_cca, display=c("sites"))
plot(vegdat_cca, display=c("species", "sites", "cn"))
plot(vegdat_cca, display=c("species", "sites", "cn"), type = "text")

#### Some graphics on diversity meassures
ggplot(data = vegdat_div, aes(x = Distance, y = Shannon)) + 
  geom_boxplot(notch = TRUE) + 
  theme_bw()

ggplot(data = vegdat_div_long[vegdat_div_long$Variable != "SpecNbr",], 
       aes(x = Distance, y = Value, fill = Variable)) + 
  geom_boxplot(notch = FALSE) + 
  theme_bw()

ggplot(data = vegdat_div, aes(x = Distance, y = Evenness)) + 
  geom_boxplot(notch = FALSE) + 
  theme_bw()

ggplot(data = vegdat_div_distsum, aes(x = Distance, y = Shannon, group=1)) + 
  geom_line(linetype = "dashed") + 
  geom_point() + 
  theme_bw()



#### Some graphics on NMDS
stressplot(nmds)
ordiplot(nmds, type="n", main = "metaMDS Analysis")
orditorp(nmds,display="species",col="red",air=0.01)
orditorp(nmds,display="sites",cex=1.25,air=0.01)



#### Some graphics on BP
groups = substr(rownames(vegdat_mtrx_pres_abs), 3, 6)

colors = as.factor(groups)
levels(colors) = c("#d73027", "#fc8d59", "#fee08b", 
                   "#d9ef8b", "#91cf60","#1a9850")
colors = as.character(colors)

distance = as.numeric(groups)

titles = c("Spatial Turnover", "Nestedness", "Total Dissimilarity")

i = 2

for(i in seq(3)){
  act_beta = bp_nmds[[i]]
  
  stressplot(act_beta)
  
  ordiplot(act_beta, type = "n", main = titles[i])
  ordihull(act_beta,groups=groups,draw="polygon",col="grey90",label=F)
  orditorp(act_beta, display="sites", col=colors, cex=1.25,air=0.01)
  
  ordiplot(act_beta, type = "n", main =  titles[i])
  ordispider (act_beta,groups=groups,draw="polygon",col="grey20",label=F)
  orditorp(act_beta, display="sites", col=colors, cex=1.25,air=0.01)
  
  # ordiplot(act_beta, type = "n", main = "Spatial Turnover")
  # ordisurf(act_beta, distance, col = "green")
}



