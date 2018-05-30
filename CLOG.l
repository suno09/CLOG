%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include "CLOG.tab.h"
#include "PTS.h"

extern int nb_ligne, nb_colonne;
extern YYSTYPE yylval;

PTS tete = NULL, p, q, l = NULL;

void lookup(char *nomE, PTS *l)
{
	for(*l=tete;*l && strcmp((*l)->nomE, nomE);*l=(*l)->svt);
}

void inserer(char *nomE, char* codE)
{
	lookup(nomE, &p);
	if(!p)
	{
		p = malloc(sizeof(struct TS));
		strcpy(p->nomE, nomE);
		strcpy(p->codE, codE);
		strcpy(p->typeE, "-----");
		p->taille = 0;
		p->define = 0;
		p->svt = NULL;
		if(!tete) tete = p;
		else q->svt = p;
		q = p;
	}
}

int sameTypeE(char *nomE1, char *typeE)
{
	PTS k;
	lookup(nomE1, &k);
	if(k && !strcmp(k->typeE, typeE)) return 1;
	return 0;
}
 
int isDefine(char* nomE)
{
	PTS k;
	lookup(nomE, &k);
	if(k && strcmp(k->typeE, "-----")) return 1;
	return 0;
}

void afficher ()
{
	FILE *fich = fopen("TS.ts", "w+");
	PTS t;
	int i, j, k;
	system("cls");
    system("mode con: cols=163");
    puts("******************************************************************  Table des Symbols ************************************************************************\n");
	fprintf(fich, "******************************************************************  Table des Symbols ************************************************************************\n");
    puts("+-----------------+-----------------+-----------------+--------------------+------------------+");
	fprintf(fich, "+-----------------+-----------------+-----------------+--------------------+------------------+\n");
    puts("|  Numero Entite  |    Nom Entite   |   Code Entite   |     Type Entite    |  Taille (OCTET)  |");
	fprintf(fich, "|  Numero Entite  |    Nom Entite   |   Code Entite   |     Type Entite    |  Taille (OCTET)  |\n");
    puts("+-----------------+-----------------+-----------------+--------------------+------------------+");
	fprintf(fich, "+-----------------+-----------------+-----------------+--------------------+------------------+\n");
	for(t=tete,i=1;t;t=t->svt,i++)
	{
		printf("+       %-9d | %-16s| %-16s| %-19s| %-17d| \n", i, t->nomE, t->codE, t->typeE, t->taille);
		fprintf(fich, "+       %-9d | %-16s| %-16s| %-19s| %-17d| \n", i, t->nomE, t->codE, t->typeE, t->taille);
		puts("|-----------------+-----------------+-----------------+--------------------+------------------+");
		fprintf(fich, "|-----------------+-----------------+-----------------+--------------------+------------------+\n");
	}
	fclose(fich);
	puts("Vous pouvez voir la table des symbols sue le fichier \"TS.ts\"\n");
}
%}
lettre [a-zA-Z]
chiffre [0-9]+
entier \([-+]{chiffre}\)|{chiffre}
reel \([-+]{chiffre}\.{chiffre}\)|{chiffre}\.{chiffre}
motcle READ|DISPLAY|IF|ELSE|FOR|END|VECTOR|INTEGER|FLOAT|CHAR|STRING|CONST|G|L|GE|LE|EQ|DI|AND|OR|NOT
idf [A-Z]({lettre}|{chiffre}|_)*
sep [ \t]
chaine \"([^"\n]|\\\")*\"
caractere \'.\'
comment \/\/.*
%%
{sep} {
		if(yytext[0] == '\t') nb_colonne += 4;
		else nb_colonne++;
	}
\n { nb_ligne++; nb_colonne = 1; }
{reel} {
			float f;
			if(yytext[1] == '-') f = atof(yytext+2) * (-1);
			else if(yytext[1] == '+') f = atof(yytext+2);
			else f = atof(yytext);
			inserer(yytext, "CstReel");
			nb_colonne+=yyleng;
			yylval.real = f;
			return reel;
		}
{entier} {
			int i;
			if(yytext[1] == '-') i = atoi(yytext+2) * (-1);
			else if(yytext[1] == '+') i = atoi(yytext+2);
			else i = i = atoi(yytext);
			if(i > -32769 && i < 32768)
			{
				inserer(yytext, "CstEntier");
				nb_colonne+=yyleng;
				yylval.integer = i;
				return entier;
			}
			else printf("\tErreur lexical, line %d, colonne %d: %s\n", nb_ligne, nb_colonne++, yytext);
		}
{caractere} {
				inserer(yytext, "CstCaractere");
				nb_colonne+=yyleng;
				yylval.car = yytext[1];
				return caractere;
			}
{chaine} {
			inserer(yytext, "CstChaine");
			nb_colonne+=yyleng;
			yylval.string = strdup(yytext);
			return chaine;
		}
{motcle} {
			char s[20] = "MC_";
			inserer(yytext, strcat(s, yytext));
			nb_colonne+=yyleng;
			switch(yytext[0])
			{
				case 'S': return MC_STRING; break;
				case 'V': return MC_VECTOR; break;
				case 'C': if(!strcmp(yytext, "CHAR")) return MC_CHAR; else return MC_CONST; break;
				case 'F': if(!strcmp(yytext, "FLOAT")) return MC_FLOAT; else return MC_FOR; break;
				case 'I': if(!strcmp(yytext, "INTEGER")) return MC_INTEGER; else return MC_IF; break;
				case 'R': return MC_READ; break;
				case 'D': if(strcmp(yytext, "DISPLAY") == 0) return MC_DISPLAY; else return MC_DI; break; 
				case 'A': return MC_AND; break;
				case 'O': return MC_OR; break;
				case 'N': return MC_NOT; break;
				case 'G': if(!strcmp(yytext, "G")) return MC_G; else return MC_GE; break;
				case 'L': if(!strcmp(yytext, "L")) return MC_L; else return MC_LE; break;
				case 'E': if(!strcmp(yytext, "ELSE")) return MC_ELSE; else if(!strcmp(yytext, "END")) return MC_END; else return MC_EQ; break;
			}	
		}
{idf} {
		if(yyleng < 9)
		{
			inserer(yytext, "Idf");
			nb_colonne+=yyleng;
			yylval.string = strdup(yytext);
			return idf;
		}
		else printf("\tErreur lexical, line %d, colonne %d: %s\n", nb_ligne, nb_colonne++, yytext);
	}
{comment}
[-+*/={}\[\]\\.,;\(\)@$%#&:|] { inserer(yytext, strdup(yytext)); nb_colonne+=yyleng; return yytext[0]; }
. printf("\tErreur lexical, line %d, colonne %d: %s\n", nb_ligne, nb_colonne++, yytext);
