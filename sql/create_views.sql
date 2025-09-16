## vw_jornada_espiritual
  
CREATE OR REPLACE VIEW vw_jornada_espiritual AS
SELECT 
  v.id AS visitante_id,
  v.nome,
  v.telefone,
  v.cidade,
  v.genero,
  v.estado_civil,
  v.data_cadastro,
  v.membro,

  -- FASES PRINCIPAIS (mapeadas pela tabela 'status' + 'fases')
  MAX(CASE WHEN f.descricao = 'INICIO' THEN s.data_cadastro END) AS fase_inicio,
  MAX(CASE WHEN f.descricao = 'PEDIDO_ORACAO' THEN s.data_cadastro END) AS fase_pedido_oracao,
  MAX(CASE WHEN f.descricao = 'INTERESSE_DISCIPULADO' THEN s.data_cadastro END) AS fase_interesse_discipulado,
  MAX(CASE WHEN f.descricao = 'LINK_WHATSAPP' THEN s.data_cadastro END) AS fase_link_whatsapp,
  MAX(CASE WHEN f.descricao = 'AGUARDANDO_ATUALIZACAO' THEN s.data_cadastro END) AS fase_aguardando_atualizacao,
  MAX(CASE WHEN f.descricao = 'ATUALIZAR_CADASTRO' THEN s.data_cadastro END) AS fase_atualizar_cadastro,
  MAX(CASE WHEN f.descricao = 'FIM' THEN s.data_cadastro END) AS fase_fim,

  -- CONVERSÕES REAIS (da tabela acolhidos)
  a.situacao AS situacao_acolhido,

  -- DISCIPULADO
  di.status_inscricao AS status_discipulado,
  d.nome_discipulado AS grupo_discipulado,

  -- CONTAGENS
  COUNT(DISTINCT c.id) AS total_criancas_no_kids,
  COUNT(DISTINCT mc.id) AS cestas_entregues

FROM visitantes v
LEFT JOIN status s ON v.id = s.visitante_id
LEFT JOIN fases f ON s.fase_id = f.id
LEFT JOIN acolhidos a ON v.telefone = a.telefone
LEFT JOIN discipulado_inscricoes di ON v.id = di.id_participante
LEFT JOIN discipulados d ON di.id_discipulado = d.id_discipulado
LEFT JOIN familia_membros fm ON v.id = fm.id_pessoa
LEFT JOIN criancas c ON fm.id_familia = c.id_familia
LEFT JOIN movimento_cestas mc ON fm.id_familia = mc.id_familia

GROUP BY 
  v.id, v.nome, v.telefone, v.cidade, v.genero, v.estado_civil, v.data_cadastro, v.membro,
  a.situacao, di.status_inscricao, d.nome_discipulado;

## vw_familias_vulneraveis
  
CREATE OR REPLACE VIEW vw_familias_vulneraveis AS
SELECT 
  fc.id AS id_familia,
  fc.id_visitante_responsavel,
  v.nome AS nome_responsavel,
  v.telefone,
  fc.numero_pessoas,
  fc.numero_filhos,
  fc.renda_mensal_familia,
  fc.condicao_moradia,
  fc.tipo_moradia,
  fc.necessidades_especificas,
  fc.data_cadastro,
  COUNT(mc.id) AS cestas_recebidas,
  SUM(CASE WHEN mc.data_entrega >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 1 ELSE 0 END) AS cestas_ultimos_30_dias,
  MAX(c.data_checkin) AS ultima_visita_kids
FROM familias_cestas fc
JOIN visitantes v ON fc.id_visitante_responsavel = v.id
LEFT JOIN movimento_cestas mc ON fc.id = mc.id_familia
LEFT JOIN checkins c ON c.crianca_id IN (
  SELECT id FROM criancas WHERE id_familia = fc.id_familia
)
WHERE fc.ativo = 1
GROUP BY fc.id, v.nome, v.telefone; 

## vw_performance_kids

CREATE OR REPLACE VIEW vw_performance_kids AS
SELECT 
  c.turma,
  COUNT(ch.id) AS total_checkins,
  SUM(CASE WHEN ch.status = 'presente' THEN 1 ELSE 0 END) AS presentes,
  SUM(CASE WHEN ch.status = 'alerta_enviado' THEN 1 ELSE 0 END) AS alertas_enviados,
  SUM(CASE WHEN ch.status = 'pai_veio' THEN 1 ELSE 0 END) AS pai_veio,
  SUM(CASE WHEN ch.status = 'acalmou_sozinha' THEN 1 ELSE 0 END) AS acalmou_sozinha,
  AVG(TIMESTAMPDIFF(MINUTE, ch.data_checkin, ch.data_checkin)) AS duracao_media_minutos,
  p.nome AS professor_responsavel
FROM criancas c
JOIN checkins ch ON c.id = ch.crianca_id
JOIN professores p ON ch.responsavel_retirada = p.nome
WHERE ch.data_checkin >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY c.turma, p.nome;

## vw_conversao_por_canal

CREATE OR REPLACE VIEW vw_conversao_por_canal AS
SELECT 
  CASE 
    WHEN v.origem = 'Bot' THEN 'WhatsApp Bot'
    WHEN v.origem = 'Presencial' THEN 'Presencial'
    WHEN v.indicacao LIKE '%amigo%' THEN 'Indicação'
    WHEN v.indicacao LIKE '%redes%' THEN 'Redes Sociais'
    ELSE 'Outro'
  END AS canal_origem,
  COUNT(*) AS total_visitantes,
  SUM(v.membro = 1) AS convertidos_para_membros,
  SUM(a.situacao IN ('Aceitou Jesus', 'Reconciliado')) AS decisoes_espirituais,
  ROUND(SUM(a.situacao IN ('Aceitou Jesus', 'Reconciliado')) * 100.0 / COUNT(*), 1) AS taxa_conversao
FROM visitantes v
LEFT JOIN acolhidos a ON v.telefone = a.telefone
GROUP BY canal_origem
ORDER BY taxa_conversao DESC;

## vw_alertas_pastorais
CREATE OR REPLACE VIEW vw_alertas_pastorais AS
SELECT 
  'ALERTA: Famílias com cadastro desatualizado' AS tipo,
  CONCAT('Há ', COUNT(*), ' famílias com cadastro pendente há mais de 7 dias.') AS mensagem,
  COUNT(*) AS valor,
  'vermelho' AS cor
FROM vw_familias_vulneraveis
WHERE fase_atualizar_cadastro IS NOT NULL 
  AND fase_atualizar_cadastro < DATE_SUB(CURDATE(), INTERVAL 7 DAY)

UNION ALL

SELECT 
  'MILAGRE: Conversões via WhatsApp',
  CONCAT('Das ', COUNT(*), ' pessoas que receberam o link do WhatsApp, ', 
         SUM(situacao_acolhido = 'Aceitou Jesus'), ' se converteram.'),
  SUM(situacao_acolhido = 'Aceitou Jesus'),
  'verde'
FROM vw_jornada_espiritual
WHERE fase_link_whatsapp IS NOT NULL 
  AND situacao_acolhido = 'Aceitou Jesus'

UNION ALL

SELECT 
  'OPORTUNIDADE: Pedido de Oração → Discipulado',
  CONCAT('Das ', COUNT(*), ' pessoas que pediram oração, ',
         SUM(fase_interesse_discipulado IS NOT NULL), ' mostraram interesse em discipulado.'),
  SUM(fase_interesse_discipulado IS NOT NULL),
  'amarelo'
FROM vw_jornada_espiritual
WHERE fase_pedido_oracao IS NOT NULL

UNION ALL

SELECT 
  'CUIDADO: Crianças em risco emocional',
  CONCAT('Há ', SUM(alertas_enviados > 0), ' crianças com alertas de necessidade emocional nos últimos 30 dias.'),
  SUM(alertas_enviados > 0),
  'laranja'
FROM vw_performance_kids;
