# Como contribuir para o UNISOULS

Obrigado por considerar contribuir! Seu esforço ajuda a tornar o UNISOULS um projeto melhor.

## 🛠️ Configuração do Ambiente

Para começar a desenvolver, você precisará dos seguintes softwares:

1.  **Godot Engine 4.5 (versão estável):** O projeto foi desenvolvido com esta versão. Você pode baixá-la do site oficial.
2.  **Git** (para controle de versão).

**Passos para Configuração:**

1.  **Clone o Repositório:**
	```bash
	git clone [https://github.com/lmitsuol/UNISOULS.git](https://github.com/lmitsuol/UNISOULS.git)
	cd UNISOULS
	```
2.  **Abra o Projeto no Godot:**
	* Abra o Godot Engine.
	* Na tela inicial, clique em "Importar" e selecione o arquivo `project.godot` dentro da pasta que você acabou de clonar.

---

## 🐛 Abrir Issues

Se você encontrar um problema ou tiver uma ideia de melhoria, por favor, abra uma issue no GitHub.

* **Reportando Bugs:**
	* Descreva o que aconteceu de forma clara.
	* Liste os passos exatos para **reproduzir** o problema.
	* Informe a versão do Godot e o sistema operacional que você está usando.
* **Sugestão de Funcionalidades:**
	* Explique a ideia, como ela seria usada no jogo e qual valor ela adicionaria.

---

## 📝 Padrões e Estilo de Código

Para manter a consistência e facilitar a manutenção, seguimos estas diretrizes:

* **Scripts GDScript:**
	* Siga o estilo de código padrão do Godot (como a documentação oficial da linguagem).
	* Use o **PascalCase** para nomes de classes (`class_name MinhaClasse`).
	* Use o **snake_case** para variáveis, funções e nomes de arquivos.
	* Use anotações de tipo sempre que possível.
* **Organização de Arquivos:**
	* Assets e scripts devem ser organizados nas pastas lógicas apropriadas (e.g., scripts de UI em `res://UI/`, modelos em `res://Assets/Models/`).

---

## 🔨 Pull Requests (PR)

Esta é a melhor maneira de ter seu código integrado ao projeto!

1.  **Crie uma Branch:** Crie uma branch específica a partir da `main` (ou da branch de desenvolvimento, se houver):
	* Para novas funcionalidades: `feature/nome-da-feature`
	* Para correção de bugs: `bugfix/nome-do-bug`
2.  **Commits Descritivos:** Faça commits pequenos e atômicos. A mensagem de commit deve explicar *o que* foi feito e, idealmente, *o porquê*.
3.  **Testes Locais:** Certifique-se de que suas alterações não quebraram nenhuma funcionalidade existente e que o projeto roda sem erros no editor.
4.  **Revisão:** O PR será revisado por um mantenedor, que poderá solicitar alterações. Por favor, seja paciente e receptivo ao feedback.
5.  **Documentação:** Se a sua contribuição afeta a jogabilidade ou inclui uma nova funcionalidade, atualize qualquer documentação relevante.

---

## 🤝 Código de Conduta

Ao contribuir para o UNISOULS, você concorda em seguir nosso **Código de Conduta**.
