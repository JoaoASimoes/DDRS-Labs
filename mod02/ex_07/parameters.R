parameters = function() {
  LinkCapacity<<-100e3
  Flows<<-list(list(sourcetype=2,arrivalrate=10,packetsize=1000,priority=1),   # alta prioridade
               list(sourcetype=2,arrivalrate=83,packetsize=1000,priority=2))   # baixa prioridade
  endTime<<-10000*(1/10)   # 1000 s
}
