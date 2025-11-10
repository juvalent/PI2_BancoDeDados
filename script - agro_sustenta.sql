-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema agro_sustenta
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema agro_sustenta
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `agro_sustenta` DEFAULT CHARACTER SET utf8 ;
USE `agro_sustenta` ;

-- -----------------------------------------------------
-- Table `agro_sustenta`.`Cooperativa`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`Cooperativa` (
  `CNPJ` VARCHAR(18) NOT NULL,
  `nome` VARCHAR(60) NOT NULL,
  `email` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`CNPJ`),
  UNIQUE INDEX `CPF_UNIQUE` (`CNPJ` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`Endereco`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`Endereco` (
  `logradouro` VARCHAR(60) NOT NULL,
  `numero` INT NOT NULL,
  `bairro` VARCHAR(45) NOT NULL,
  `cidade` VARCHAR(45) NOT NULL,
  `CEP` VARCHAR(9) NOT NULL,
  `UF` CHAR(2) NOT NULL,
  `Cooperativa_CNPJ` VARCHAR(18) NOT NULL,
  PRIMARY KEY (`Cooperativa_CNPJ`),
  CONSTRAINT `fk_Endereco_Cooperativa1`
    FOREIGN KEY (`Cooperativa_CNPJ`)
    REFERENCES `agro_sustenta`.`Cooperativa` (`CNPJ`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`Telefone`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`Telefone` (
  `idTelefone` INT NOT NULL AUTO_INCREMENT,
  `numero` VARCHAR(15) NOT NULL,
  `Cooperativa_CNPJ` VARCHAR(18) NOT NULL,
  PRIMARY KEY (`idTelefone`),
  UNIQUE INDEX `idTelefone_UNIQUE` (`idTelefone` ASC) VISIBLE,
  INDEX `fk_Telefone_Cooperativa1_idx` (`Cooperativa_CNPJ` ASC) VISIBLE,
  CONSTRAINT `fk_Telefone_Cooperativa1`
    FOREIGN KEY (`Cooperativa_CNPJ`)
    REFERENCES `agro_sustenta`.`Cooperativa` (`CNPJ`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`Armazem`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`Armazem` (
  `idArmazem` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(60) NOT NULL,
  PRIMARY KEY (`idArmazem`),
  UNIQUE INDEX `idArmazem_UNIQUE` (`idArmazem` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`Estoque`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`Estoque` (
  `idEstoque` INT NOT NULL AUTO_INCREMENT,
  `entradaLotes` DATETIME NOT NULL,
  `saidaLotes` DATETIME NOT NULL,
  `saldoDisponivel` INT NOT NULL,
  `Armazem_idArmazem` INT NOT NULL,
  PRIMARY KEY (`idEstoque`),
  UNIQUE INDEX `idEstoque_UNIQUE` (`idEstoque` ASC) VISIBLE,
  INDEX `fk_Estoque_Armazem1_idx` (`Armazem_idArmazem` ASC) VISIBLE,
  CONSTRAINT `fk_Estoque_Armazem1`
    FOREIGN KEY (`Armazem_idArmazem`)
    REFERENCES `agro_sustenta`.`Armazem` (`idArmazem`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`Rastreio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`Rastreio` (
  `idRastreio` INT NOT NULL AUTO_INCREMENT,
  `destinatario` VARCHAR(60) NOT NULL,
  `Cooperativa_CNPJ` VARCHAR(18) NOT NULL,
  PRIMARY KEY (`idRastreio`),
  UNIQUE INDEX `idRastreio_UNIQUE` (`idRastreio` ASC) VISIBLE,
  INDEX `fk_Rastreio_Cooperativa1_idx` (`Cooperativa_CNPJ` ASC) VISIBLE,
  CONSTRAINT `fk_Rastreio_Cooperativa1`
    FOREIGN KEY (`Cooperativa_CNPJ`)
    REFERENCES `agro_sustenta`.`Cooperativa` (`CNPJ`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`Distribuicao`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`Distribuicao` (
  `idDistribuicao` INT NOT NULL AUTO_INCREMENT,
  `dataSaida` DATETIME NOT NULL,
  `statusEntrega` VARCHAR(15) NOT NULL,
  `Rastreio_idRastreio` INT NOT NULL,
  PRIMARY KEY (`idDistribuicao`),
  UNIQUE INDEX `idDistribuicao_UNIQUE` (`idDistribuicao` ASC) VISIBLE,
  INDEX `fk_Distribuicao_Rastreio1_idx` (`Rastreio_idRastreio` ASC) VISIBLE,
  CONSTRAINT `fk_Distribuicao_Rastreio1`
    FOREIGN KEY (`Rastreio_idRastreio`)
    REFERENCES `agro_sustenta`.`Rastreio` (`idRastreio`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`Lote`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`Lote` (
  `idLote` INT NOT NULL AUTO_INCREMENT,
  `especie` VARCHAR(60) NOT NULL,
  `quantidade` INT NOT NULL,
  `validade` DATE NOT NULL,
  `descricao` VARCHAR(250) NOT NULL,
  `Armazem_idArmazem` INT NOT NULL,
  PRIMARY KEY (`idLote`),
  UNIQUE INDEX `idLote_UNIQUE` (`idLote` ASC) VISIBLE,
  INDEX `fk_Lote_Armazem1_idx` (`Armazem_idArmazem` ASC) VISIBLE,
  CONSTRAINT `fk_Lote_Armazem1`
    FOREIGN KEY (`Armazem_idArmazem`)
    REFERENCES `agro_sustenta`.`Armazem` (`idArmazem`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`Sementes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`Sementes` (
  `idSementes` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(60) NOT NULL,
  `especie` VARCHAR(60) NOT NULL,
  `quantidade` INT NOT NULL,
  `Lote_idLote` INT NOT NULL,
  PRIMARY KEY (`idSementes`, `Lote_idLote`),
  UNIQUE INDEX `idSementes_UNIQUE` (`idSementes` ASC) VISIBLE,
  INDEX `fk_Sementes_Lote1_idx` (`Lote_idLote` ASC) VISIBLE,
  CONSTRAINT `fk_Sementes_Lote1`
    FOREIGN KEY (`Lote_idLote`)
    REFERENCES `agro_sustenta`.`Lote` (`idLote`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`EnderecoArmazem`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`EnderecoArmazem` (
  `logradouro` VARCHAR(60) NOT NULL,
  `numero` INT NOT NULL,
  `bairro` VARCHAR(45) NOT NULL,
  `cidade` VARCHAR(45) NOT NULL,
  `CEP` VARCHAR(9) NOT NULL,
  `UF` CHAR(2) NOT NULL,
  `Armazem_idArmazem` INT NOT NULL,
  PRIMARY KEY (`Armazem_idArmazem`),
  CONSTRAINT `fk_EnderecoArmazem_Armazem1`
    FOREIGN KEY (`Armazem_idArmazem`)
    REFERENCES `agro_sustenta`.`Armazem` (`idArmazem`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`TelefoneArmazem`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`TelefoneArmazem` (
  `idTelefoneArmazem` INT NOT NULL AUTO_INCREMENT,
  `numero` VARCHAR(15) NOT NULL,
  `Armazem_idArmazem` INT NOT NULL,
  PRIMARY KEY (`idTelefoneArmazem`),
  UNIQUE INDEX `idTelefoneArmazem_UNIQUE` (`idTelefoneArmazem` ASC) VISIBLE,
  INDEX `fk_TelefoneArmazem_Armazem1_idx` (`Armazem_idArmazem` ASC) VISIBLE,
  CONSTRAINT `fk_TelefoneArmazem_Armazem1`
    FOREIGN KEY (`Armazem_idArmazem`)
    REFERENCES `agro_sustenta`.`Armazem` (`idArmazem`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `agro_sustenta`.`Distribuicao_Armazem`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `agro_sustenta`.`Distribuicao_Armazem` (
  `Distribuicao_idDistribuicao` INT NOT NULL,
  `Armazem_idArmazem` INT NOT NULL,
  PRIMARY KEY (`Distribuicao_idDistribuicao`, `Armazem_idArmazem`),
  INDEX `fk_Distribuicao_has_Armazem_Armazem1_idx` (`Armazem_idArmazem` ASC) VISIBLE,
  INDEX `fk_Distribuicao_has_Armazem_Distribuicao1_idx` (`Distribuicao_idDistribuicao` ASC) VISIBLE,
  CONSTRAINT `fk_Distribuicao_has_Armazem_Distribuicao1`
    FOREIGN KEY (`Distribuicao_idDistribuicao`)
    REFERENCES `agro_sustenta`.`Distribuicao` (`idDistribuicao`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Distribuicao_has_Armazem_Armazem1`
    FOREIGN KEY (`Armazem_idArmazem`)
    REFERENCES `agro_sustenta`.`Armazem` (`idArmazem`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
