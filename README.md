### CryptoCore-SD192: IP Core de Criptografia em Verilog



## 📌 Sobre o Projeto

Este repositório contém o desenvolvimento de um IP Core voltado para criptografia em hardware, desenvolvido para a disciplina \*\*SD192 – Trabalho Orientado I\*\* da Especialização em Microeletrônica (Front-End Digital).



O objetivo é projetar um módulo eficiente, modular e parametrizável, seguindo as boas práticas de design RTL para ASICs e FPGAs.



\## 🚀 Status do Desenvolvimento

1\. ### [x] Definição do Escopo e Algoritmo

2\. ### [x] Modelagem da Arquitetura (FSM e Datapath)

3\. ### [x] Codificação RTL (Verilog)

4\. ### [x] Verificação Funcional (Testbench)

5\. ### [ ] Documentação Final



## 🛠️ Especificações Técnicas

\* \*\*Linguagem:\*\* Verilog HDL (IEEE 1364-2005)

\* \*\*Algoritmo:\*\* TEA e PRESENT

\* \*\*Interface:\*\* Handshake simples (Ready/Valid) ou Barramento (tipo APB/AXI)

\* \*\*Arquitetura:\*\* FSM + Datapath com suporte a ECD



## 📂 Como Contribuir

1\. Realize o \*\*Fork\*\* do projeto.

2\. Crie uma \*\*Branch\*\* para sua feature (`git checkout -b feature/nome-da-feature`).

3\. Certifique-se de que o código Verilog segue as regras de linting (indentação de 2 ou 4 espaços, nomes de sinais claros).

4\. Suba seus arquivos de RTL e o Testbench correspondente.

5\. Abra um \*\*Pull Request\*\* detalhando as alterações e os resultados da simulação.


\## 📂 Estrutura de Pastas

1\.   /doc  : Documentação, diagramas de blocos, especificações do algoritmo e o relatório final.

2\.   /rtl : Seus arquivos fonte em Verilog (.v).

3\.  /sim : Arquivos de simulação, incluindo o Testbench e scripts de ferramentas (como Icarus Verilog ou ModelSim).

4\.  /scripts : Scripts de automação (TCL, Python ou Shell).

5\.  /syn : (Opcional para este módulo) Relatórios de síntese lógica..




\## 📝 Licença

Este projeto é para fins acadêmicos.

