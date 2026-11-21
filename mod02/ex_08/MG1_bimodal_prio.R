#Copia do mg1_bimodal.R, alterada para o exercicio 8 c):
#M/G/1 com servico bimodal e prioridade estrita nao-preemptiva aos ratos.
#Unica alteracao na simulacao: quando o servidor fica livre, em vez de servir
#o primeiro job da fila, serve o primeiro rato da fila (se nao houver ratos,
#serve o primeiro da fila). Um job em servico nunca e interrompido.
#Tambem se acumula o atraso de ratos e elefantes em separado.

#input parameters
Ro=0.5 #system utilization
s1=1 #mice size
p1=0.99 #mice probability
s2=101 #elephants size
p2=0.01 #elephants probability
StoppingCondition=10000

#parameters calculated from the input parameters
ServiceRate=1/(s1*p1+s2*p2)
ArrivalRate=ServiceRate*Ro

#M/G/1 Bimodal com prioridade aos ratos
Time=0
NumQueueCompleted=0
ServerStatus=0
NumInQueue=0
AcumDelay=0
AcumDelayRatos=0 #novo: atraso acumulado dos ratos
AcumDelayElefantes=0 #novo: atraso acumulado dos elefantes
NumRatos=0 #novo: numero de ratos que sairam da fila
NumElefantes=0 #novo: numero de elefantes que sairam da fila
QueueArrivalTime=c()
QueueJobSize=c()
EventList=c(rexp(1,ArrivalRate),Inf)
#simulation cycle
while (NumQueueCompleted<StoppingCondition) {
  NextEventType=which.min(EventList)
  Time=EventList[NextEventType]
  if (NextEventType==1) {
    EventList[1]=Time+rexp(1,ArrivalRate)
    JobSize=ifelse(runif(1)<p1,s1,s2)
    if (ServerStatus==1) {
      QueueArrivalTime=c(QueueArrivalTime,Time)
      QueueJobSize=c(QueueJobSize,JobSize)
      NumInQueue=NumInQueue+1
    } else{
      NumQueueCompleted=NumQueueCompleted+1
      #novo: conta o job na sua classe (atraso em fila = 0)
      if (JobSize==s1) {
        NumRatos=NumRatos+1
      } else {
        NumElefantes=NumElefantes+1
      }
      ServerStatus=1
      EventList[2]=Time+JobSize
    }
  }
  else {
    if (NumInQueue==0) {
      ServerStatus=0
      EventList[2]=Inf
    } else {
      #novo: escolhe o primeiro rato da fila; se nao houver ratos, o primeiro da fila
      Next=which(QueueJobSize==s1)[1]
      if (is.na(Next)) {
        Next=1
      }
      Delay=Time-QueueArrivalTime[Next]
      AcumDelay=AcumDelay+Delay
      JobSize=QueueJobSize[Next]
      #novo: acumula o atraso na classe do job
      if (JobSize==s1) {
        AcumDelayRatos=AcumDelayRatos+Delay
        NumRatos=NumRatos+1
      } else {
        AcumDelayElefantes=AcumDelayElefantes+Delay
        NumElefantes=NumElefantes+1
      }
      QueueArrivalTime=QueueArrivalTime[-Next]
      QueueJobSize=QueueJobSize[-Next]
      NumInQueue=NumInQueue-1
      NumQueueCompleted=NumQueueCompleted+1
      EventList[2]=Time+JobSize
    }
  }
}
AvgDelayPrio=AcumDelay/NumQueueCompleted
AvgDelayRatos=AcumDelayRatos/NumRatos
AvgDelayElefantes=AcumDelayElefantes/NumElefantes

#M/G/1 com prioridades nao-preemptivas (teoria)
es2=s1^2*p1+s2^2*p2
R=ArrivalRate*es2/2 #trabalho residual medio
rho1=ArrivalRate*p1*s1 #carga dos ratos
wqRatos=R/(1-rho1)
wqElefantes=R/((1-rho1)*(1-Ro))
wqPrio=p1*wqRatos+p2*wqElefantes

cat(sprintf("Arrival rate = %.2f",ArrivalRate),"\n")
cat(sprintf("Service rate = %.2f",ServiceRate),"\n")
cat("\n")

#tabela com o atraso medio em fila (teorico e estimado), total e por classe
tabelaPrio=data.frame(
  Classe=c("Total","Ratos","Elefantes"),
  Wq_teorico=c(wqPrio,wqRatos,wqElefantes),
  Wq_simulado=c(AvgDelayPrio,AvgDelayRatos,AvgDelayElefantes)
)
tabelaPrio[,2:3]=round(tabelaPrio[,2:3],3)
print(tabelaPrio,row.names=FALSE)