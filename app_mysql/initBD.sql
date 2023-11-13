CREATE DATABASE IF NOT EXISTS safe_monitor;
USE safe_monitor;

CREATE TABLE IF NOT EXISTS empresa (
   IdEmpresa INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
   nome_empresa VARCHAR(255) NOT NULL,
   cnpj VARCHAR(45) NOT NULL,
   razao_social VARCHAR(255) NOT NULL,
   telefone_celular VARCHAR(15) NOT NULL,
   telefone_fixo VARCHAR(14) NULL,
   telefone2_celular VARCHAR(15) NULL,
   tipo_instituicao VARCHAR(30) NOT NULL,
   privada VARCHAR(1) NOT NULL,
   cep VARCHAR(9) NULL,
   cidade VARCHAR(80) NULL,
   estado VARCHAR(80) NULL,
   rua VARCHAR(150) NULL,
   numero INT(5) NULL,
   complemento VARCHAR(45) NULL,
   bairro VARCHAR(45) NULL,
   CONSTRAINT chkTipoInstituicao CHECK(tipo_instituicao in ("escola", "faculdade", "universidade")),
   CONSTRAINT chkPrivada CHECK (privada in ("s", "n"))
   );


CREATE TABLE IF NOT EXISTS usuario (
   idUsuario INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
   email  VARCHAR(120) NOT NULL,
   senha VARCHAR(30) NOT NULL,
   nome  VARCHAR(45) NULL,
   cargo VARCHAR(45) NULL,
   cadastrar TINYINT NOT NULL,
   leitura TINYINT NOT NULL,
   alterar TINYINT NOT NULL,
   deletar TINYINT NOT NULL,
   capturar TINYINT NOT NULL,
   fk_empresa INT NOT NULL,
   CONSTRAINT chk_cadastro CHECK (cadastrar IN (0, 1)), 
   CONSTRAINT chk_leitura CHECK (leitura IN (0, 1)), 
   CONSTRAINT chk_alterar CHECK (alterar IN (0, 1)), 
   CONSTRAINT chk_deletar CHECK (deletar IN (0, 1)), 
   CONSTRAINT chk_capturar CHECK (capturar IN (0, 1)), 
   CONSTRAINT const_fkEmpresa FOREIGN KEY (fk_empresa) REFERENCES empresa (IdEmpresa)
);

CREATE TABLE IF NOT EXISTS sala_de_aula (
   idSala INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
   nome VARCHAR(45) NOT NULL,
   localizacao TEXT NOT NULL,
   fk_usuario INT NOT NULL,
   fk_empresa INT NOT NULL,
   CONSTRAINT const_fkUsuario FOREIGN KEY (fk_usuario)  REFERENCES usuario(idUsuario),
   CONSTRAINT const_sala_fkEmpresa FOREIGN KEY (fk_empresa)  REFERENCES empresa(idEmpresa)
  );


CREATE TABLE IF NOT EXISTS maquina (
   idMaquina INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
   nome VARCHAR(45),
   modelo VARCHAR(45) NULL,
   numero_serie VARCHAR(15) NULL,
   marca  VARCHAR(30) NULL,
   sistema_operacional VARCHAR(15) NULL,
   arquitetura INT NULL,
   fabricante VARCHAR(50) NULL,
   fk_sala INT NOT NULL,
   fk_empresa INT NOT NULL,
   CONSTRAINT const_fkSala FOREIGN KEY (fk_sala) REFERENCES sala_de_aula (idSala),
   CONSTRAINT const_maquina_fkEmpresa FOREIGN KEY (fk_empresa)  REFERENCES empresa(idEmpresa)
);

CREATE TABLE IF NOT EXISTS historico_usuarios (
  idHistoricoUsuario INT NOT NULL AUTO_INCREMENT,
  fk_usuario INT NOT NULL,
  fk_maquina INT NOT NULL,
  data_hora DATETIME default current_timestamp,
  PRIMARY KEY (idHistoricoUsuario, fk_usuario, fk_maquina),
  CONSTRAINT  FOREIGN KEY (fk_usuario) REFERENCES usuario (idUsuario),
  CONSTRAINT fk_historicoUsuarios_maquina FOREIGN KEY (fk_maquina) REFERENCES maquina (idMaquina));
  

CREATE TABLE IF NOT EXISTS janela (
  idJanela INT NOT NULL AUTO_INCREMENT,
  pid INT NULL,
  titulos TEXT NULL,
  comandos TEXT NULL,
  dt_hora DATETIME default current_timestamp,
  stt VARCHAR(20),
  matar TINYINT(1) NULL, 
  fk_maquina INT NOT NULL,
  PRIMARY KEY (idJanela, fk_maquina),
  CONSTRAINT chk_stt CHECK (stt IN ("Fechada", "Aberta")),
  CONSTRAINT const_fk_maquina FOREIGN KEY (fk_maquina)REFERENCES maquina (idMaquina)
);



CREATE TABLE IF NOT EXISTS processo (
  idProcesso INT NOT NULL AUTO_INCREMENT,
  pid INT NULL,
  nome VARCHAR(80) NULL,
  usoCPU DECIMAL(5,2) NULL,
  bytesUtilizados DECIMAL(5,2) NULL,
  dt_hora DATETIME default current_timestamp,
  fk_maquina INT NOT NULL,
  PRIMARY KEY (idProcesso, fk_maquina),
  CONSTRAINT const_fkMaquina FOREIGN KEY (fk_maquina) REFERENCES maquina (idMaquina));


CREATE TABLE IF NOT EXISTS  componente (
  idComponente INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  nome VARCHAR(45) NULL,
  descricao TEXT NULL
);

CREATE TABLE IF NOT EXISTS  tipo_componente (
  fk_componente INT NOT NULL,
  fk_maquina INT NOT NULL,
  PRIMARY KEY (fk_componente, fk_maquina),
  CONSTRAINT const_tipoComponente_fkMaquina FOREIGN KEY (fk_maquina) REFERENCES maquina (idMaquina),
  CONSTRAINT const_fkComponente FOREIGN KEY (fk_componente) REFERENCES componente(idComponente));

CREATE TABLE IF NOT EXISTS tipo_dados (
  idTipoDados INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  nome VARCHAR(45) NULL,
  limite_inicial DECIMAL(5,2) NULL,
  limite_final DECIMAL(5,2) NULL
  );
  
  
CREATE TABLE IF NOT EXISTS captura_dados (
  idCaptura INT NOT NULL AUTO_INCREMENT,
  valor_monitorado DECIMAL(7,2) NULL,
  dt_hora DATETIME default current_timestamp,
  fk_componente INT NOT NULL,
  fk_maquina INT NOT NULL,
  fk_tiposDados INT NOT NULL,
  PRIMARY KEY (idCaptura, fk_componente, fk_maquina, fk_tiposDados),
  CONSTRAINT const_captura_fk_componente FOREIGN KEY (fk_componente) REFERENCES tipo_componente (fk_componente),
  CONSTRAINT const_fk_maquinaCaptura FOREIGN KEY (fk_maquina) REFERENCES tipo_componente (fk_maquina),
  CONSTRAINT const_fk_tipoDdos FOREIGN KEY (fk_tiposDados) REFERENCES tipo_dados (idTipoDados));
  
  
CREATE TABLE IF NOT EXISTS tipo_notificacao(
  idTipo_notificacao INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
  nome VARCHAR(45) NULL,
  cor VARCHAR(6) NULL
);

CREATE TABLE IF NOT EXISTS notificacao (
  data_hora DATETIME default current_timestamp,
  fk_tipoNotificacao INT NOT NULL,
  fk_Captura INT NOT NULL,
  fk_captura_tiposDados INT NOT NULL,
  fk_captura_maquina INT NOT NULL,
  fk_captura_componente INT NOT NULL,
  PRIMARY KEY (fk_tipoNotificacao, fk_Captura, fk_captura_tiposDados, fk_captura_maquina, fk_captura_componente),
  CONSTRAINT fk_notificacao_tipoNotificacao FOREIGN KEY (fk_tipoNotificacao) REFERENCES tipo_notificacao (idTipo_notificacao),
  CONSTRAINT fk_notificacao_captura FOREIGN KEY (fk_Captura) REFERENCES captura_dados (idCaptura),
  CONSTRAINT fk_notificacao_tipoDados FOREIGN KEY (fk_captura_tiposDados ) REFERENCES captura_dados (fk_tiposDados),
  CONSTRAINT fk_notificacao_maquina FOREIGN KEY (fk_captura_maquina) REFERENCES captura_dados (fk_maquina),
  CONSTRAINT fk_notificacao_componente FOREIGN KEY (fk_captura_componente) REFERENCES captura_dados (fk_componente)
);

-- INSERIR DADOS EMPRESA
INSERT INTO empresa (nome_empresa, cnpj, razao_social, telefone_celular, tipo_instituicao, privada) 
VALUES ("SPTECH", "11.111.111/1111-09", "São Paulo Tech School","(11) 11111-1111", "faculdade", "s");


-- INSERIR DADOS USUÁRIO
INSERT INTO usuario (`email`, `senha`, `nome`, `cargo`, `cadastrar`, `leitura`, `alterar`, `deletar`, `capturar`, `fk_empresa`) 
	VALUES  ("admin@gmail.com", "12345", "Alessandro", "Presidente", 1, 1, 1, 1, 1, 1),
		    ("admin@sptech.school", "12345", "Marcio", "Administrador de TI", 1, 1, 1, 1, 1, 1),
			("melissa@sptech.school", "12345", "Melissa", NULL, 0, 0, 0, 0, 1, 1);

-- INSERIR DADOS SALA
INSERT INTO sala_de_aula (nome, localizacao, fk_usuario, fk_empresa) 
	VALUES ("Sala 1", "1° andar", 2, 1),
	       ("Sala 5", "6° andar, lado B", 3, 1);

-- INSERIR DADOS MÁQUINAS
INSERT INTO maquina (`idMaquina`, `modelo`, `numero_serie`, `marca`, `fk_sala`, `fk_empresa`) 
VALUES (NULL, 'Modelo1', 'Serie1', 'Marca1',  1, 1),
       (NULL, 'Modelo2', 'Serie2', 'Marca2',  2, 1),
       (NULL, 'Modelo3', 'Serie3', 'Marca3',  1, 1),
       (NULL, 'Modelo4', 'Serie4', 'Marca4', 2, 1);

-- INSERIR DADOS COMPONENTE
INSERT INTO componente (`nome`) VALUES ("Processador"),
										("Rede"),
										("Ram"),
										("Disco");


-- INSERIR DADOS TIPOS DADOS
INSERT INTO tipo_dados(`nome`) 
					VALUES ("Uso CPU"),
						   ("Uso Disco"),
						   ("Uso Ram"),
						   ("Pacotes Enviados"),
              ("Pacotes Recibidos");







