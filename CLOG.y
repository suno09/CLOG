%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "PTS.h"
#include "LISTE.h"

int nb_ligne = 1, nb_colonne = 1, executer = 1, ind, pas, fin, x = 1, n = 1;
char text[100], text2[100], ch[100], x3[100], ch2[100];
PTS l;
LISTE t = NULL, tetc = NULL, tetf = NULL;
LISTECH tch = NULL;
QUADRUPLET tetq, p;
SAVE tets = NULL;
extern char *yytext;
%}
%union
{
	int integer;
	float real;
	char car;
	char *string;
}
%token <string>idf MC_READ MC_DISPLAY MC_IF MC_ELSE MC_FOR MC_END MC_VECTOR MC_INTEGER MC_FLOAT MC_CHAR MC_STRING MC_CONST MC_G MC_L MC_GE MC_LE MC_EQ MC_DI MC_AND MC_OR MC_NOT
		<real>reel <integer>entier <car>caractere <string>chaine
		'-' '+' '*' '/' '=' '{' '}' '[' ']' '.' ',' ';' '(' ')' '@' '$' '%' '#' '&' ':' '\\' '\'' '|' '"'
%type<integer> IND IND1 IND2 CONDITION CONDITION1 CONDITION2 CONDITION3 RCONDITION1 RCONDITION2
%type<car> OPC
%type<string> RINST_AFF RVAR RIDF RVIDF
%%
PROGRAM: HEAD '{' '{' DECLARATION '}' '{' BODY '}' '}' { 
															puts ("\n\tProgramme lexicalement et syntaxiquement juste ^_^\n");
															p = Quad(" ", "", "", "");
															finQuad(tetq)->svt = p;
															YYACCEPT;
														}
;
HEAD : idf {
				p = Quad("", "", "", $1);
				tetq = p;
			}
;
DECLARATION: LIST_VAR DECLARATION |
;
LIST_VAR: TYPE ':' VAR ';' | MC_CONST ':' VCONST ';' | VECTEUR
;
TYPE: MC_INTEGER { strcpy(text, "INTEGER"); }
	| MC_FLOAT { strcpy(text, "FLOAT"); }
	| MC_CHAR { strcpy(text, "CHAR"); }
	| MC_STRING { strcpy(text, "STRING"); }
;
VAR: RVAR '|' VAR | RVAR
;
RVAR: idf {
			if(!isDefine($1))
			{
				lookup($1, &l);
				strcpy(l->typeE, text);
			}
			else printf("\tErreur Semantique, line %d, colonne %d: %s: double declaration\n", nb_ligne, nb_colonne, $1);
		}
;
VCONST: RIDF '=' entier {
							lookup($1, &l);
							if(!strcmp(l->typeE, "-----"))
							{
								strcpy(l->typeE, "INTEGER CONST");
								l->define = 1;
								sprintf(text, "%d", $3);
								p = Quad("=", text, "", $1); n++;
								finQuad(tetq)->svt = p;
							}
						}
		| RIDF '=' reel {
							lookup($1, &l);
							if(!strcmp(l->typeE, "-----"))
							{
								strcpy(l->typeE, "FLOAT CONST");
								l->define = 1;
								sprintf(text, "%.2f", $3);
								p = Quad("=", text, "", $1); n++;
								finQuad(tetq)->svt = p;
							}
						}
		| RIDF '=' caractere {
							lookup($1, &l);
							if(!strcmp(l->typeE, "-----"))
							{
								strcpy(l->typeE, "CHAR CONST");
								l->define = 1;
								sprintf(text, "'%c'", $3);
								p = Quad("=", text, "", $1); n++;
								finQuad(tetq)->svt = p;
							}
						}
		| RIDF '=' chaine {
							lookup($1, &l);
							if(!strcmp(l->typeE, "-----"))
							{
								strcpy(l->typeE, "STRING CONST");
								l->define = 1;
								sprintf(text, "%s", $3);
								p = Quad("=", text, "", $1); n++;
								finQuad(tetq)->svt = p;
							}
						}
;
VECTEUR: MC_VECTOR ':' TYPE ':' VAR_VECT ';'
;
VAR_VECT: RIDF '[' entier ',' entier ']' {
											if(!isDefine($1))
											{
												lookup($1, &l);
												strcpy(l->typeE, strcat(text, " VECTOR"));
												if($3 > $5) printf("\tErreur Semantique, line %d, colonne %d: %s: borne inferieure > taille\n", nb_ligne, nb_colonne-1, $1);
												else if($5 <= 0) printf("\tErreur Semantique, line %d, colonne %d: %s: la taille <= 0\n", nb_ligne, nb_colonne-1, $1);
												else{
													l->define = 1;
													sprintf(text, "%d", $3);
													sprintf(text2, "%d", $5);
													p = Quad("BOUNDS", text, text2, ""); n++;
													finQuad(tetq)->svt = p;
													p = Quad("ADEC", $1, "", ""); n++;
													finQuad(tetq)->svt = p;
												}
											}
										}
;
RIDF: idf {
				lookup($1, &l); strcpy($$, $1);
				if(strcmp(l->typeE, "-----")) printf("\tErreur Semantique, line %d, colonne %d: %s: double declaration\n", nb_ligne, nb_colonne, $1);
			}
;
BODY: LIST_INST BODY |
;
LIST_INST: INST_IF | INST_FOR | INST_DISPLAY | INST_READ | INST_AFF
;
INST_DISPLAY: MC_DISPLAY '(' chaine ')' ';'
				{
					int i = 0, existe = 0;
					for(i=0;i<strlen($3);i++)
						switch($3[i])
						{
							case '$':
							case '%':
							case '#':
							case '&':
								if($3[i-1] != '\\')
								{
									existe++;
									if(existe == 1) printf("\tErreur Semantique, line %d, colonne %d: %c: manque identificateur de signe de formatage\n", nb_ligne, nb_colonne-2, $3[i]);
								}
								break;
						}
					if(existe > 1) printf("\tErreur Semantique, line %d, colonne %d: nombre superieure de signe de formatage\n", nb_ligne, nb_colonne-2);	
					QUADRUPLET p = Quad("DISPLAY", "", "", ""); n++;
					finQuad(tetq)->svt = p;
				}
				| MC_DISPLAY '(' chaine ':' idf ')' ';'
				{
					if(!isDefine($5)) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas declare\n", nb_ligne, nb_colonne-2, $5);
					else
					{
						int i = 0, existe = 0;
						lookup($5, &l);
						if(strstr(l->typeE, "VECTOR")) printf("\tErreur Semantique, line %d, colonne %d: %s: manque d'indice\n", nb_ligne, nb_colonne-2, $5);
						for(i=0;i<strlen($3);i++)
							if(!existe)
							{
								switch($3[i])
								{
									case '$':
											if($3[i-1] != '\\'){
												if(!sameTypeE($5, "INTEGER")) printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $5, $3[i]);
												else if(!l->define) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas initialise\n", nb_ligne, nb_colonne-2, $5);
												existe++;
											}
											break;
									case '%':
											if($3[i-1] != '\\'){
												if(!sameTypeE($5, "FLOAT")) printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $5, $3[i]);
												else if(!l->define) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas initialise\n", nb_ligne, nb_colonne-2, $5);
												existe++;
											}
											break;
									case '#':
											if($3[i-1] != '\\'){
												if(!sameTypeE($5, "STRING")) printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne-2, $5, $3[i]);
												else if(!l->define) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas initialise\n", nb_ligne, nb_colonne-2, $5);
												existe++;
											}
											break;
									case '&':
											if($3[i-1] != '\\'){
												if(!sameTypeE($5, "CHAR")) printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne-2, $5, $3[i]);
												else if(!l->define) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas initialise\n", nb_ligne, nb_colonne-2, $5);
												existe++;
											}
											break;
								}
							}
						if(existe > 1) printf("\tErreur Semantique, line %d, colonne %d: nombre superieure de signe de formatage\n", nb_ligne, nb_colonne);
						if(!existe) printf("\tErreur Semantique, line %d, colonne %d: %s: manque signe de formatage\n", nb_ligne, nb_colonne, $5);	
					}
					QUADRUPLET p = Quad("DISPLAY", "", "", l->nomE); n++;
					finQuad(tetq)->svt = p;
				}
				| MC_DISPLAY '(' chaine ':' idf '[' IND ']' ')' ';'
				{
					if(!isDefine($5)) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas declare\n", nb_ligne, nb_colonne-2, $5);
					else
					{
						lookup($5, &l);
						if(!strstr(l->typeE, "VECTOR")) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas de type vecteur\n", nb_ligne, nb_colonne-2, $5);
						else if($7 < l->deb || $7 > l->deb + l->fin - 1) printf("\tErreur Semantique, line %d, colonne %d: erreur d'indice de vecteur\n", nb_ligne, nb_colonne-2);
						else{
							int i = 0, existe = 0;
							for(i=0;i<strlen($3);i++)
								if(!existe)
									switch($3[i])
									{
										case '$':
												if($3[i-1] != '\\'){
													if(!strstr(l->typeE, "INTEGER")) printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $5, $3[i]);
													else if(!l->define) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas initialise\n", nb_ligne, nb_colonne-2, $5);
													existe++;
												}
												break;
										case '%':
												if($3[i-1] != '\\'){
													if(!strstr(l->typeE, "FLOAT")) printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $5, $3[i]);
													else if(!l->define) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas initialise\n", nb_ligne, nb_colonne-2, $5);
													existe++;
												}
												break;
										case '#':
												if($3[i-1] != '\\'){
													if(!strstr(l->typeE, "STRING")) printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $5, $3[i]);
													else if(!l->define) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas initialise\n", nb_ligne, nb_colonne-2, $5);
													existe++;
												}
												break;
										case '&':
												if($3[i-1] != '\\'){
													if(!strstr(l->typeE, "CHAR")) printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $5, $3[i]);
													else if(!l->define) printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas initialise\n", nb_ligne, nb_colonne-2, $5);
													existe++;
												}
												break;
									}
							if(existe > 1) printf("\tErreur Semantique, line %d, colonne %d: nombre superieure de signe de formatage\n", nb_ligne, nb_colonne);
							if(!existe) printf("\tErreur Semantique, line %d, colonne %d: %s: manque signe de formatage\n", nb_ligne, nb_colonne, $5);	
						}
					}
					QUADRUPLET p = Quad("DISPLAY", "", "", ""); n++;
					finQuad(tetq)->svt = p;
					sprintf(p->res, "%s[%s]", l->nomE, popCH(&tch));
				}
;
INST_READ: MC_READ '(' chaine ':' '@' idf ')' ';'
												{
													lookup($6, &l);
													if(strlen($3) > 3) 
														printf("\tErreur Semantique, line %d, colonne %d: %s: Erreur signe de formatage\n", nb_ligne, nb_colonne, $3);
													if(!isDefine($6)) 
														printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas declare\n", nb_ligne, nb_colonne, $6);
													else if(strstr(l->typeE, "CONST")) 
														printf("\tErreur Semantique, line %d, colonne %d: %s: Identificateur constant\n", nb_ligne, nb_colonne-2, $6);
													else if(strstr(l->typeE, "VECTOR")) 
														printf("\tErreur Semantique, line %d, %d: %s: manque d'indice identificateur vecteur\n", nb_ligne, nb_colonne-2, $6);
													else switch($3[1])
													{
														case '$':
																if(!sameTypeE($6, "INTEGER"))
																		printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $6, $3[1]);
																break;
														case '%':
																if(!sameTypeE($6, "FLOAT"))
																		printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $6, $3[1]);
																break;
														case '#':
																if(!sameTypeE($6, "STRING"))
																		printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $6, $3[1]);
																break;
														case '&':
																if(!sameTypeE($6, "CHAR"))
																		printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $6, $3[1]);
																break;
													}
													QUADRUPLET p = Quad("READ", "", "", l->nomE); n++;
													finQuad(tetq)->svt = p;
												}
			| MC_READ '(' chaine ':' '@' idf '[' IND ']' ')' ';'
																{
																	lookup($6, &l);
																	if(strlen($3) > 3)
																		printf("\tErreur Semantique, line %d, colonne %d: %s: Erreur signe de formatage\n", nb_ligne, nb_colonne, $3);
																	if(!isDefine($6)) 
																		printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur %s n'est pas declare\n", nb_ligne, nb_colonne, $6);
																	else if(strstr(l->typeE, "CONST")) 
																		printf("\tErreur Semantique, line %d, colonne %d: %s: Identificateur constant\n", nb_ligne, nb_colonne, $6);
																	else if(!strstr(l->typeE, "VECTOR")) 
																		printf("\tErreur Semantique, line %d, colonne %d: %s: Incompatible de type vecteur\n", nb_ligne, nb_colonne, $6);
																	else if($8 < l->deb || $8 > l->deb + l->fin - 1) 
																		printf("\tErreur Semantique, line %d, colonne %d: %s: erreur d'indice de l'identificateur\n", nb_ligne, nb_colonne, $6);
																	else switch($3[1])
																	{
																		case '$':
																				if(!strstr(l->typeE, "INTEGER"))
																					printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $6, $3[1]);
																				break;
																		case '%':
																				if(!strstr(l->typeE, "FLOAT"))
																					printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $6, $3[1]);
																				break;
																		case '#':
																				if(!strstr(l->typeE, "STRING"))
																					printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $6, $3[1]);
																				break;
																		case '&':
																				if(!strstr(l->typeE, "CHAR"))
																					printf("\tErreur Semantique, line %d, colonne %d: %s: Difference signe de formatage %c\n", nb_ligne, nb_colonne, $6, $3[1]);
																				break;
																	}
																	QUADRUPLET p = Quad("READ", "", "", ""); n++;
																	finQuad(tetq)->svt = p;
																	sprintf(p->res, "%s[%s]", l->nomE, popCH(&tch));
																}
;
INST_AFF: RINST_AFF '=' EXPA ';' {
								if(!ifERROR(t)){
									lookup($1, &l);
									if(!strstr(l->typeE, "VECTOR")){
										if(!strcmp(l->typeE, "STRING") && t->val){
											l->define = 1;
											p = Quad("=", popCH(&tch), "", l->nomE); n++;
											finQuad(tetq)->svt = p;
											x = 1;
										}
										else if(strcmp(l->typeE, "STRING") && !t->val){
											l->define = 1;
											p = Quad("=", popCH(&tch), "", l->nomE); n++;
											finQuad(tetq)->svt = p;
											x = 1;
										}
										else printf("\tErreur Semantique, line %d, colonne %d: Incompatible type d'affectation\n", nb_ligne, nb_colonne);
									}
									else{
										lookup($1, &l);
										if(strstr(l->typeE, "STRING") && t->val){
											l->define = 1;
											strcpy(ch, popCH(&tch));
											strcpy(x3, popCH(&tch));
											p = Quad("=", ch, "", x3); n++;
											finQuad(tetq)->svt = p;
											x = 1;
										}
										else if(!strstr(l->typeE, "STRING") && !t->val){
											l->define = 1;
											strcpy(ch, popCH(&tch));
											strcpy(x3, popCH(&tch));
											p = Quad("=", ch, "", x3); n++;
											finQuad(tetq)->svt = p;
											x = 1;
										}
										else printf("\tErreur Semantique, line %d: colonne %d: Incompatible type d'affectation\n", nb_ligne, nb_colonne);
									}
								}
								clear(&t);
							}
;
RINST_AFF: idf { 	
				lookup($1, &l); add(&t, -1);
				if(!isDefine($1)) 
					printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas declare\n", nb_ligne, nb_colonne, $1);
				else if(strstr(l->typeE, "VECTOR")) 
					printf("\tErreur Semantique, line %d, colonne %d: %s: Manque d'indice identificateur vecteur\n", nb_ligne, nb_colonne, $1);
				else if(strstr(l->typeE, "CONST")) 
					printf("\tErreur Semantique, line %d, colonne %d: %s: Identificateur constant\n", nb_ligne, nb_colonne, $1);
				else { 
					strcpy($$, $1); 
					clear(&t); 
				} 
			}
		| RVIDF '[' IND ']'{
							lookup($1, &l);
							if($3 < l->deb || $3 > l->deb + l->fin - 1)
								printf("\tErreur Semantique, line %d, colonne %d: %s: Erreur d'indice d'identificateur\n", nb_ligne, nb_colonne, $1);
							else { 
								strcpy($$, $1); ind = $3; 
								clear(&t); 
								sprintf(ch, "%s[%s]", l->nomE, popCH(&tch)); 
								addCH(&tch, ch);
						}
		}
;
RVIDF: idf {
			lookup($1, &l);  add(&t, -1);
			if(!isDefine($1)) 
				printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas declare\n", nb_ligne, nb_colonne, $1);
			else if(strstr(l->typeE, "CONST")) 
				printf("\tErreur Semantique, line %d, colonne %d: %s: Identificateur constant\n", nb_ligne, nb_colonne, $1);
			else if(!strstr(l->typeE, "VECTOR"))
				printf("\tErreur Semantique, line %d, colonne %d: %s: Incompatible de type vecteur\n", nb_ligne, nb_colonne, $1);
			else strcpy($$, $1);
	}
;
INST_IF: MC_IF '(' RINST_IF1 ')' ':' BODY INST_IF2 MC_END {
							popListe(&tetc);
							while(tetc && popListe(&tetc));
						}
;
RINST_IF1: CONDITION {
						if(tetc) add(&tetc, tetc->val);
						if(tetc && tetc->val == -1){
							if(!strcmp(tets->q->e1, "d"))
								while(tetc && popListe(&tetc)) sprintf(popSave(&tets)->e1, "(%d)", n+2);
							else sprintf(popSave(&tets)->e1, "(%d)", n+2);
							p = Quad("BR", "", "", ""); n++;
							finQuad(tetq)->svt = p;
							add(&tetc, -1);
							addSave(&tets, p);
						}
						add(&tetc, 0);
					}
;
INST_IF2: MC_ELSE RINST_IF3 ':' BODY { sprintf(popSave(&tets)->e1, "(%d)", n+1); }
		| {
			if(!strcmp(tets->q->e1, "d")){
				popListe(&tetc);
				while(tetc && popListe(&tetc) == 1) sprintf(popSave(&tets)->e1, "(%d)", n+1);
			}
			else sprintf(popSave(&tets)->e1, "(%d)", n+1);
		}
;
RINST_IF3: {
				if(!strcmp(tets->q->e1, "d")){
					popListe(&tetc);
					if(tetc->val == -1)
						sprintf(popSave(&tets)->e1, "(%d)", n+1);
					while(tetc && popListe(&tetc) == 1) sprintf(popSave(&tets)->e1, "(%d)", n+1);
				}
				else sprintf(popSave(&tets)->e1, "(%d)", n+2);
				p = Quad("BR", "", "", ""); n++;
				finQuad(tetq)->svt = p;
				addSave(&tets, p);
			}
;
INST_FOR: MC_FOR '(' RINST_FOR1 ':' RINST_FOR2 ')' BODY MC_END { 
																	pas = 0; fin = 0;
																	QUADRUPLET p = Quad("BR", "", "", ""); n++;
																	sprintf(p->e1, "(%d)", popListe(&tetf));
																	finQuad(tetq)->svt = p;
																	sprintf(popSave(&tets)->e1, "(%d)", n+1);
																}
;
RINST_FOR1: idf {
					lookup($1, &l); pas = 0; fin = 0;
					if(!isDefine($1))
						printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas declare\n", nb_ligne, nb_colonne, $1);
					else if(strstr(l->typeE, "VECTOR")) 
						printf("\tErreur Semantique, line %d, colonne %d: %s: Manque d'indice identificateur vecteur\n", nb_ligne, nb_colonne, $1);
					else if(strstr(l->typeE, "CONST")) 
						printf("\tErreur Semantique, line %d, colonne %d: %s: Identificateur constant\n", nb_ligne, nb_colonne, $1); 
					strcpy(text2, $1);
					QUADRUPLET p;
					if(strstr(l->typeE, "INTEGER")) p = Quad("=", "1", "", text2);
					else p = Quad("=", "'A'", "", text2);
					n++;
					finQuad(tetq)->svt = p;
					p = Quad("BR", "", "", ""); n++;
					finQuad(tetq)->svt = p;
					addSave(&tets, p);
					add(&tetf, n+1);
				}
;
RINST_FOR2: IND RINST_FOR3 ':' IND {
							pas = (int)$1;
							fin = (int)$4;
							QUADRUPLET p = Quad("BG", "", text2, popCH(&tch)); n++;
							finQuad(tetq)->svt = p;
							addSave(&tets, p);
						}
;
RINST_FOR3: {
				sprintf(x3, "t%d", x++);
				QUADRUPLET p = Quad("+", text2, popCH(&tch), x3); n++;
				finQuad(tetq)->svt = p;
				p = Quad("=", x3, "", text2); n++; 
				finQuad(tetq)->svt = p;
				sprintf(popSave(&tets)->e1, "(%d)", n+1);
				x = 1;
			}
;
CONDITION: RCONDITION1 MC_OR CONDITION1 { 
											if($1 == 1 || $3 == 1) $$ = 1;
											else if($1 && $3) $$ = -1;
											else $$ = 0;	
											strcpy(tets->q->e1, "d");
											add(&tetc, -1);
											strcpy(tets->q->opr, ch2);
										}
		| CONDITION1 { $$ = $1; }
;
CONDITION1: RCONDITION2 MC_AND CONDITION2 { 
											if($1 == -1 || $3 == -1) $$ = -1;
											else if($1 && $3) $$ = 1;
											else $$ = 0;											
											strcpy(tets->q->e1, "d");
											add(&tetc, 1);
										}
			| CONDITION2 { $$ = $1; }
;
CONDITION2: MC_NOT CONDITION3  { $$ = -$2; }
			| CONDITION3 { $$ = $1; }
;
CONDITION3: EXPA '.' OPC '.' EXPA {
									if(!ifERROR(t)){
										if(ifSAME(t)){
											if(t->val)
												switch($3)
												{
													case 'e': if(!strcmp($<string>1, $<string>5)) $$ = 1; else $$ = -1; strcpy(ch, "BNE"); break;
													case 'd': if(strcmp($<string>1, $<string>5)) $$ = 1; else $$ = -1; strcpy(ch, "BE"); break;
													default: printf("\tErreur Semantique, line %d, colonne %d: Incompatible operateurs de comparaison\n", nb_ligne, nb_colonne);
													$$ = 0;
												}
											else switch($3)
											{
												case 'e': if($<real>1 == $<real>5) $$ = 1; else $$ = -1; strcpy(ch, "BNE"); strcpy(ch2, "BE"); break;
												case 'd': if($<real>1 != $<real>5) $$ = 1; else $$ = -1; strcpy(ch, "BE"); strcpy(ch2, "BNE"); break;
												case 'l': if($<real>1 < $<real>5) $$ = 1; else $$ = -1; strcpy(ch, "BGE"); strcpy(ch2, "BL"); break;
												case 'L': if($<real>1 <= $<real>5) $$ = 1; else $$ = -1; strcpy(ch, "BG"); strcpy(ch2, "BLE"); break;
												case 'g': if($<real>1 > $<real>5) $$ = 1; else $$ = -1; strcpy(ch, "BLE"); strcpy(ch2, "BG"); break;
												case 'G': if($<real>1 >= $<real>5) $$ = 1; else $$ = -1; strcpy(ch, "BL"); strcpy(ch2, "BGE"); break;
											}
										}
										else printf("\tErreur Semantique, line %d, colonne %d: Comparaison de differents types\n", nb_ligne, nb_colonne);
									}
									else $$ = 0; // erreur comparaison
									p = Quad(ch, "", "", ""); n++;
									addSave(&tets, p);
									strcpy(p->res, popCH(&tch));
									strcpy(p->e2, popCH(&tch));
									finQuad(tetq)->svt = p;	
								}
			| '(' CONDITION ')' { $$ = $2; }
;
RCONDITION1: CONDITION {
							$$ = $1;
							strcpy(tets->q->opr, ch2);
							strcpy(tets->q->e1, "d");
						}
;
RCONDITION2: CONDITION1 {
							$$ = $1;
							strcpy(tets->q->e1, "d");
						}
;
EXPA: EXPA '+' EXP1 {
						if(!ifERROR(t)){
							if(!ifSAME(t)) {
								printf("\tErreur Semantique, line %d, colonne %d: Expression avec differents types\n", nb_ligne, nb_colonne); 
								add(&t, -1); 
							}
							else if(t->val){
								char val1[1000] = "";
								strcpy(val1, $<string>1);
								strcpy(val1+strlen(val1)-1, $<string>3 + 1);
								strcpy($<string>$, val1);
								sprintf(x3, "t%d", x++);
								strcpy(ch, popCH(&tch));
								p = Quad("+", popCH(&tch), ch, x3); n++;
								addCH(&tch, x3);
								finQuad(tetq)->svt = p;
							}
							else { $<real>$ = $<real>1 + $<real>3; 
								sprintf(x3, "t%d", x++);
								strcpy(ch, popCH(&tch));
								p = Quad("+", popCH(&tch), ch, x3); n++;
								addCH(&tch, x3);
								finQuad(tetq)->svt = p;
							}
						}
					}
	| EXPA '-' EXP1 {
						if(!ifERROR(t)){
							if(!ifSAME(t)) { 
								printf("\tErreur Semantique, line %d, colonne %d: Expression avec differents types\n", nb_ligne, nb_colonne);
								add(&t, -1); 
							}
							else if(t->val) { 
								printf("\tErreur Semantique, line %d, %d: Expression avec incompatible type (STRING)\n", nb_ligne, nb_colonne); 
								add(&t, -1); 
							}
							else { 
								$<real>$ = $<real>1 - $<real>3; 
								sprintf(x3, "t%d", x++);
								strcpy(ch, popCH(&tch));
								p = Quad("-", popCH(&tch), ch, x3); n++;
								addCH(&tch, x3);
								finQuad(tetq)->svt = p;
							}
						}
					}
	| EXP1 {
				if(!ifERROR(t)) { 
					if(!t->val) $<real>$ = (float)$<real>1;
					else strcpy($<string>$, $<string>1);
				}
				else add(&t, -1);
			}
;
EXP1: EXP1 '*' EXP2 {
						if(!ifERROR(t)){
							if(!ifSAME(t)) { 
								printf("\tErreur Semantique, line %d, colonne %d: Expression avec differents types\n", nb_ligne, nb_colonne);
								add(&t, -1); 
							}
							else if(t->val) { 
								printf("\tErreur Semantique, line %d, %d: Expression avec incompatible type (STRING)\n", nb_ligne, nb_colonne); 
								add(&t, -1); 
							}
							else { 
								$<real>$ = $<real>1 * $<real>3; 
								sprintf(x3, "t%d", x++);
								strcpy(ch, popCH(&tch));
								p = Quad("*", popCH(&tch), ch, x3); n++;
								addCH(&tch, x3);
								finQuad(tetq)->svt = p;
							}
						}
					}
	| EXP1 '/' EXP2 {
						if(!ifERROR(t)){
							if(!ifSAME(t)) { 
								printf("\tErreur Semantique, line %d, colonne %d: Expression avec differents types\n", nb_ligne, nb_colonne);
								add(&t, -1); 
							}
							else if(t->val) { 
								printf("\tErreur Semantique, line %d, %d: Expression avec incompatible type (STRING)\n", nb_ligne, nb_colonne); 
								add(&t, -1); 
							}
							else if($<real>3 == 0) { 
								printf("\tErreur Semantique, line %d, colonne %d: Division par zero\n", nb_ligne, nb_colonne); 
								add(&t, -1);
							}
							else { 
								if(executer)  $<real>$ = $<real>1 / $<real>3; 
								sprintf(x3, "t%d", x++);
								strcpy(ch, popCH(&tch));
								p = Quad("/", popCH(&tch), ch, x3); n++;
								addCH(&tch, x3);
								finQuad(tetq)->svt = p;
							}
						}
					}
	| EXP2 { 
			if(!ifERROR(t)) {
				if(!t->val) $<real>$ = (float)$<real>1;
				else strcpy($<string>$, $<string>1);
			}
			else add(&t, -1);
		}
;
EXP2: idf {
			add(&t, -1);
			lookup($1, &l);
			if(!isDefine($1)) 
				printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas declare\n", nb_ligne, nb_colonne, $1);
			else if(strstr(l->typeE, "VECTOR")) 
				printf("\tErreur Semantique, line %d, colonne %d: %s: Manque d'indice identificateur vecteur\n", nb_ligne, nb_colonne, $1);
			else if(strstr(l->typeE, "CONST")) 
				printf("\tErreur Semantique, line %d, colonne %d: %s: Identificateur constant\n", nb_ligne, nb_colonne, $1);
			else if(!l->define) 
				printf("\tErreur Semantique, line %d, colonne %d: %s: Identificateur n'est pas initialise\n", nb_ligne, nb_colonne, $1);
			else if(strstr(l->typeE, "STRING")) { 
				t->val = 1; 
			}
			else { 
				t->val = 0; 
			}
			addCH(&tch, l->nomE);
		}
	| entier{ 
		$<real>$ = (float)$1; 
		add(&t, 0); 
		sprintf(ch, "%d", (int)$1); 
		addCH(&tch, ch);
	}
	| reel { 
		$<real>$ = $1; 
		add(&t, 0); 
		sprintf(ch, "%.2f", (float)$1);
		addCH(&tch, ch);
	}
	| caractere { 
		$<real>$ = (float)$1; 
		add(&t, 0); 
		sprintf(ch, "'%c'", (char)$1); 
		addCH(&tch, ch);
	}
	| chaine { 
		strcpy($<string>$, $1); 
		add(&t, 1); 
		sprintf(ch, "%s", $1); 
		addCH(&tch, ch);
	}
	| idf '[' IND ']' {
		add(&t, -1);
		lookup($1, &l);
		if(!isDefine($1)) 
			printf("\tErreur Semantique, line %d, colonne %d: %s: l'identificateur n'est pas declare\n", nb_ligne, nb_colonne, $1);
		else if(strstr(l->typeE, "CONST")) 
			printf("\tErreur Semantique, line %d, colonne %d: %s: Identificateur constant\n", nb_ligne, nb_colonne, $1);
		else if(!strstr(l->typeE, "VECTOR"))
			printf("\tErreur Semantique, line %d, colonne %d: %s: Incompatible de type vecteur\n", nb_ligne, nb_colonne, $1);
		else if($3 < l->deb || $3 > l->deb + l->fin - 1) 
			printf("\tErreur Semantique, line %d, colonne %d: %s: Erreur d'indice d'identificateur\n", nb_ligne, nb_colonne, $1);
		else if(strstr(l->typeE, "STRING")) {  
			t->val = 1; 
		}
		else { 
			t->val = 0; 
		}
		sprintf(ch, "%s[%s]", l->nomE, popCH(&tch));
		addCH(&tch, ch);
	}
	| '(' EXPA ')' {
						if(!ifERROR(t)){
							if(!t->val) $<real>$ = (float)$<real>2;
							else strcpy($<string>$, $<string>2);
						}
						else add(&t, -1);
					}
;
IND: IND '+' IND1 {
					$$ = $1 + $3; 
					strcpy(ch, popCH(&tch));
					sprintf(x3, "t%d", x++);
					p = Quad("+", popCH(&tch), ch, x3);  n++;
					finQuad(tetq)->svt = p;
					addCH(&tch, x3);
				}
	| IND '-' IND1 {
						$$ = $1 - $3; 
						strcpy(ch, popCH(&tch));
						sprintf(x3, "t%d", x++);
						p = Quad("-", popCH(&tch), ch, x3); n++;
						finQuad(tetq)->svt = p;
						addCH(&tch, x3);
					}
	| IND1 { $$ = $1; }
;
IND1: IND1 '*' IND2 {
						$$ = $1 * $3; 
						strcpy(ch, popCH(&tch));
						sprintf(x3, "t%d", x++);
						p = Quad("*", popCH(&tch), ch, x3); n++;
						finQuad(tetq)->svt = p;
						addCH(&tch, x3);
					}
	| IND1 '/' IND2 {
						if($3 == 0) 
							printf("\tErreur Semantique, line %d: Division par zero\n", nb_ligne); 
						else { 
								$$ = $1 / $3;
								strcpy(ch, popCH(&tch));
								sprintf(x3, "t%d", x++);
								p = Quad("/", popCH(&tch), ch, x3); n++;
								finQuad(tetq)->svt = p;
								addCH(&tch, x3);
							} 
					}
	| IND2 { $$ = $1; }
;
IND2: idf {
			lookup($1, &l);
			if(!isDefine($1))
				printf("\tErreur Semantique, line %d, colonne %d: %s: Identificateur n'est pas declare\n", nb_ligne, nb_colonne, $1);
			else if(strstr(l->typeE, "STRING") || strstr(l->typeE, "FLOAT")) 
				printf("\tErreur Semantique, line %d: colonne %d: %s: Incompatible type de l'identificateur\n", nb_ligne, nb_colonne, $1);
			else if(strstr(l->typeE, "VECTOR")) 
				printf("\tErreur Semantique, line %d, colonne %d: %s: Manque d'indice identificateur vecteur\n", nb_ligne, nb_colonne, $1);
			else if(!l->define) 
				printf("\tErreur Semantique, line %d, colonne %d: %s: Iidentificateur n'est pas initialise\n", nb_ligne, nb_colonne, $1); 
			addCH(&tch, l->nomE);
		}
	| entier{ 
			$$ = (int)$1;
			sprintf(ch, "%d", (int)$1);
			addCH(&tch, ch);
			}
	| caractere { 
				$$ = (char)$1;
				sprintf(ch, "'%c'", (char)$1);
				addCH(&tch, ch);
				}
	| idf '[' IND ']' {
						lookup($1, &l);
						if(!isDefine($1))
							printf("\tErreur Semantique, line %d, colonne %d: %s: Identificateur n'est pas declare\n", nb_ligne, nb_colonne, $1);
						else if(strstr(l->typeE, "STRING") || strstr(l->typeE, "FLOAT")) 
							printf("\tErreur Semantique, line %d: colonne %d: %s: Incompatible type de l'identificateur\n", nb_ligne, nb_colonne, $1);
						else if(!strstr(l->typeE, "VECTOR"))
							printf("\tErreur Semantique, line %d, colonne %d: %s: Incompatible de type vecteur\n", nb_ligne, nb_colonne, $1);
						else if($3 < l->deb || $3 > l->deb + l->fin - 1) 
							printf("\tErreur Semantique, line %d, colonne %d: %s: Erreur d'indice d'identificateur\n", nb_ligne, nb_colonne, $1);
						sprintf(ch, "%s[%s]", l->nomE, popCH(&tch));
						addCH(&tch, ch);
					}
	| '(' IND ')' { $$ = $2; }
; 
OPC: MC_DI { $$ = 'd'; }
	| MC_EQ { $$ = 'e'; }
	| MC_G { $$ = 'g'; }
	| MC_GE { $$ = 'G'; }
	| MC_L { $$ = 'l'; }
	| MC_LE { $$ = 'L'; }
;
%%
int yyerror(char *s)
{
	printf("\tErreur Syntaxique, line %d, colonne %d: %s\n", nb_ligne, nb_colonne++, yytext);
	return 0;
}

main ()
{
system("color 0f");
system("cls");
puts("Affichage les erreurs:\n");
yyparse();
puts("Appuyer sur n'importe touche pour afficher la table des symbols");
getch();
afficher();
puts("Les erreurs peuvent etre sur quadruplet a cause des erreurs sur votre code source !!!\n");
puts("Appuyer sur n'importe touche pour afficher le Quadruplet du programme\n");
getch();
affQuad(tetq);
}
