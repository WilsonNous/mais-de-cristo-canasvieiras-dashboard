# 🕊️ Dashboard da Colheita Integral — Mais de Cristo Canasvieiras

> _“Cada dado é um testemunho. Cada número, um milagre.”_

Este projeto é um **altar digital** criado para ajudar os pastores titulares da **Mais de Cristo Canasvieiras** a ver, em tempo real, onde o Espírito Santo está movendo-se na obra.

Não é um relatório técnico.  
É um **instrumento de discernimento pastoral** que une:

- Evangelismo pelo WhatsApp Bot  
- Acolhida espiritual  
- Cuidado infantil (AlertaKids)  
- Assistência social (cestas básicas)  
- Discipulado estruturado  

---

## ✨ Propósito

Fornecer aos pastores uma visão clara, em 5 segundos, de:

- Quem foi tocado?
- Quem está sendo cuidado?
- Onde Deus está multiplicando?

---

## 🔗 Fontes de Dados

Conectado ao banco MySQL da Hostgator com as seguintes tabelas:
- `visitantes`, `acolhidos`, `conversas`, `checkins`, `criancas`, `familias_cestas`, `discipulado_inscricoes`, `estatisticas`, `fases`, etc.

---

## 🧩 Views SQL Criadas (prontas para uso)

- [`vw_jornada_espiritual`](./sql/create_views.sql) — Fluxo completo da jornada espiritual
- [`vw_familias_vulneraveis`](./sql/create_views.sql) — Identificação de famílias em necessidade
- [`vw_performance_kids`](./sql/create_views.sql) — Monitoramento do Espaço Kids
- [`vw_conversao_por_canal`](./sql/create_views.sql) — Efetividade dos canais de evangelismo
- [`vw_alertas_pastorais`](./sql/create_views.sql) — Insights automáticos gerados pelo sistema

> 💡 Todos os scripts estão em `sql/create_views.sql`

---

## 🖥️ Como usar no Looker Studio

Veja o guia completo em:  
[📄 Guia de Conexão ao Looker Studio](./docs/05-GUIA-LOOKER-STUDIO.md)

---

## 🎨 Design & Identidade Visual

- Cores: Azul celeste (paz), Dourado (glória), Roxo (restauração), Verde (vida)  
- Fonte: Nunito Sans  
- Ícones: 👥, ✝️, 🙏, 🛒, 👶, ⚠️  
- Layout: [Ver wireframe](./assets/wireframe_dashboard.pdf)

---

## ❤️ Por que isso importa?

> _“Nós não estamos apenas medindo números. Estamos registrando o mover do Espírito Santo._  
> _Cada pedido de oração, cada criança cuidada, cada cesta entregue — é um grão de trigo caindo na terra boa.”_

Este projeto foi feito com amor por Wilson e toda a equipe da Mais de Cristo Canasvieiras.  
Se você é pastor e quer replicar isso na sua igreja — **sinta-se livre para usar, adaptar e compartilhar.**

Glória a Deus!

---

© 2025 — Mais de Cristo Canasvieiras  
Licenciado sob MIT License
