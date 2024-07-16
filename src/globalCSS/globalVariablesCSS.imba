
global css 
	body
		# colors

		@dark
			--laranja-arandu:#DE760C
			--branco-arandu:#FFFFFF
			--roxo-arandu:#660E37
			--preto-arandu:#2B2B2B
			--cinza-escuro-arandu:#676767
			--cinza-claro-arandu:#AAAAAA
			--vermelho-arandu:#CC2222
			--laranja-leve-arandu:#FDF1E5

			--principal-branco:#ffffff
			--principal-laranja:#E58320
			--apoio-roxo:#660E37
			--apoio-preto:#2B2B2B
			--apoio-dark-grey:#676767
			--apoio-light-grey:#aaaaaa
			--apoio-vermelho:#c22222
			--apoio-laranja-leve:#FDF1E5

			--ui-header:#1E1A20
			--ui-text-input:#413947
			--ui-container:#27232A
			--ui-menu-lateral:#27222B
			--uibg:#171419
			--ui-text-input:#413947
		

		# light
		@light
			--principal-branco:#ffffff   # same
			--principal-laranja:#E58320  # same
			--apoio-roxo: #CDA2C5  # A lighter shade of purple, maintaining the color theme
			--apoio-preto:#2B2B2B  # Suitable for primary text in light mode
			--apoio-dark-grey:#949494  # A slightly lighter grey for secondary text.
			--apoio-light-grey:#cccccc  # A bit darker to stand out against a light background
			--apoio-vermelho:#c22222  # same
			--apoio-laranja-leve:#FDF1E5  # same

			--ui-header:#E1E1E1  # A light grey, providing a softer look for the header.
			--ui-text-input:#F0F0F0  # A very light grey, ensuring clarity for input fields.
			--ui-container:#F5F5F5   # A slightly different shade of light grey, distinguishing it from the background.
			--ui-menu-lateral:#F2F2F2  # Another light grey, offering a subtle variation for the lateral menu.
			--uibg:#FAFAFA   # An off-white background, bright but not stark.
			--ui-text-input:#F0F0F0   # The same light grey as earlier for text inputs, ensuring consistency.

		.light
			--principal-branco:#ffffff   # same
			--principal-laranja:#E58320  # same
			--apoio-roxo: #CDA2C5  # A lighter shade of purple, maintaining the color theme
			--apoio-preto:#2B2B2B  # Suitable for primary text in light mode
			--apoio-dark-grey:#949494  # A slightly lighter grey for secondary text.
			--apoio-light-grey:#cccccc  # A bit darker to stand out against a light background
			--apoio-vermelho:#c22222  # same
			--apoio-laranja-leve:#FDF1E5  # same

			--ui-header:#E1E1E1  # A light grey, providing a softer look for the header.
			--ui-text-input:#F0F0F0  # A very light grey, ensuring clarity for input fields.
			--ui-container:#F5F5F5   # A slightly different shade of light grey, distinguishing it from the background.
			--ui-menu-lateral:#F2F2F2  # Another light grey, offering a subtle variation for the lateral menu.
			--uibg:#FAFAFA   # An off-white background, bright but not stark.
			--ui-text-input:#F0F0F0   # The same light grey as earlier for text inputs, ensuring consistency.

		# font-family
		--title-arandu:Poppins, sans-serif
		--body-arandu:Sen, sans-serif

		# @dark
		# 	--apoio-vermelho:#660E37
