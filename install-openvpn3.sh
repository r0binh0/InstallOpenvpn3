#!/usr/bin/env bash
#
# Autor:      robinho
# Manutenção: https://github.com/r0binh0
#
# ---------------------------------------------------------------------------- #
#  Este script auxilia na instalação do OpenVPN3 Ubuntu >= 20.04
#
#  Exemplos:
#      $ sudo ./install_openvpn3.sh
# ---------------------------------------------------------------------------- #
# Histórico:
#
#   v1.0 18/12/2022, Robson:
#       - Criado o script para automatizar a instalação do Openvpn3.
# ---------------------------------------------------------------------------- #
# Testado em:
#   5.0.17(1)
# ---------------------------------------------------------------------------- #

# --------------------------------- VARIÁVEIS -------------------------------- #
INFO="logger -p local0.info -t [$(basename $0)]"
ERRO="logger -p local0.err -t [$(basename $0)]"

COFF="\033[m"			# Desabilitar Cor do Text
LREDN="\033[1;31m"		# Letra Vermelha e Negrito
LGREENN="\033[1;32m"	# Letra Verde e Negrito
LBLUEN="\033[1;34m"		# Letra Azul e Negrito
LGRAYN="\033[1;37m"		# Letra Cinza e Negrito

DEPENDE=("apt-transport-https" "wget")
# ---------------------------------------------------------------------------- #

# ---------------------------------- TESTES ---------------------------------- #
[[ $UID != 0 ]] && {
	echo
	echo -e "${LREDN}Voce precisar executar esse script como root!${COFF}"
	$ERRO "Erro ao tentar executar o script sem permissionamento de root."
	echo
	exit 1
}

[[ -x "$(which openvpn3)" ]] && {
	echo
	echo -e "${LGREENN}O OpenVPN ja esta instalado!${COFF}"
	$INFO "O OpenVPN ja esta instalado!"
	echo
	exit 0
}

# ---------------------------------------------------------------------------- #

# --------------------------------- FUNÇÕES ---------------------------------- #
AtualizaRepos () {
    apt update 1> /dev/null 2>&1
}

InstalaDependencia () {
	sudo apt install -y $DEPENDE 1> /dev/null 2>&1
}

AdicionaRepoOpenVPN3 () {
	$INFO "Baixando a key do repositorio."
	sudo wget -q https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub 
	$INFO "Aplicando a key do repositorio."
	sudo apt-key add openvpn-repo-pkg-key.pub 1> /dev/null 2>&1
	DISTRO=$(lsb_release -c | awk '{print $2}')
	$INFO "Adicionando o repositorio."
	sudo wget -qO /etc/apt/sources.list.d/openvpn3.list \
	https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-$DISTRO.list
    rm openvpn-repo-pkg-key.pub
}

AdicionaArchx64 () {
	sed -i 's/deb/deb [arch=amd64]/' /etc/apt/sources.list.d/openvpn3.list
}

InstalandoOpenVPN3 () {
	apt install -y openvpn3 1> /dev/null 2>&1
}

# ---------------------------------------------------------------------------- #

# --------------------------------- EXECUÇÃO --------------------------------- #
clear

$INFO "Instalando dependencia."
echo -e "${LGRAYN}Instalando dependencia...${COFF}"
InstalaDependencia

$INFO "Adicionando repositorio do OpenVPN3."
echo -e "${LGRAYN}Adicionando repositorio...${COFF}"
AdicionaRepoOpenVPN3

$INFO "Adicionando arquitetura x64 do repositorio."
echo -e "${LGRAYN}Adicionando arquitetura x64 no repositorio...${COFF}"
AdicionaArchx64

$INFO "Atualizando repositório"
echo -e "${LGRAYN}Atualizando os repositorios...${COFF}"
AtualizaRepos

$INFO "Instalando Openvpn3."
echo -e "${LGRAYN}Instalando OpenVPN3...${COFF}"
InstalandoOpenVPN3

echo
echo -e "${LGRAYN}Para iniciar a VPN execute o comando:${COFF}"
echo -e "${LGREENN}sudo openvpn3 session-start --config <PATH>${COFF}"
echo -e "${LGRAYN}Substitua${COFF} ${LGREENN}<PATH>${COFF} ${LGRAYN}pelo \
caminho completo do arquivo de VPN.${COFF}"
echo
echo -e "${LGRAYN}Para encerrar a VPN execute o comando:${COFF}"
echo -e "${LREDN}sudo pkill openvpn3${COFF}"
echo
# ---------------------------------------------------------------------------- #