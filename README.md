# PI2_BancoDeDados

# 🌱 Agro Sustenta  

### 👩‍💻 Equipe de Desenvolvimento  
Projeto desenvolvido por **Julliane Valentin**, **Ingrid Isabelle**, **Dayane Oliveira**, **Ludmila Arlane** e **Juliana Vasconcelos**, estudantes do curso **Análise e Desenvolvimento de Sistemas – Turma 48**.  

---

## 💡 Sobre o Projeto  

O **Agro Sustenta** é uma **plataforma web** voltada para produtores rurais e cooperativas, com o objetivo de **promover rastreabilidade, controle e sustentabilidade** no uso e distribuição de sementes.  

A plataforma centraliza informações sobre **processos de fecundação**, **variações climáticas**, **características das sementes**, **recomendações de adubo** e principalmente o **rastreamento completo** do percurso das sementes — da cooperativa até o produtor.  

Com uma interface simples e acessível, o sistema busca **facilitar o acesso à informação agrícola**, melhorar o **planejamento de plantio** e **reduzir perdas** causadas por prazos e armazenamento inadequado.  

---

## 🗃️ Estrutura do Banco de Dados  

O banco de dados foi projetado para **garantir a rastreabilidade total das sementes** e integrar cooperativas, armazéns e produtores.  

### Principais Entidades:
- **Cooperativa:** armazena dados da cooperativa fornecedora (CNPJ, nome, e-mail).  
- **Armazém:** controla os locais de estocagem e suas informações de contato e endereço.  
- **Lote:** identifica cada lote de sementes (espécie, quantidade, validade).  
- **Sementes:** dados detalhados de cada tipo de semente vinculada ao lote.  
- **Estoque:** controla entradas e saídas de lotes.  
- **Distribuição:** registra entregas e status de envio.  
- **Rastreio:** vincula a cooperativa ao destino final, garantindo a rastreabilidade.  

🔗 **Resumo dos relacionamentos:**  
Cooperativas → enviam sementes → Armazéns → registram lotes → Distribuição → Rastreio → Produtor final.  

---

## 🌾 Benefícios  

- Transparência no ciclo de vida das sementes  
- Redução de desperdícios e perdas por vencimento  
- Planejamento agrícola mais eficiente  
- Incentivo à sustentabilidade e boas práticas rurais  

---


