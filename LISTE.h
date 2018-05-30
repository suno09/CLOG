#ifndef LISTE_H_INCLUDED
#define LISTE_H_INCLUDED

#include <stdlib.h>
#include <string.h>

typedef struct element *LISTE;
struct element
{
	int val;
	LISTE svt;
};

void add(LISTE *tete, int val)
{
	LISTE p = malloc(sizeof(struct element));
	p->val = val;
	p->svt = *tete;
	*tete = p;
}

void clear(LISTE *tete)
{
	LISTE temp;
	while(*tete)
	{
		temp = *tete;
		*tete = (*tete)->svt;
		free(temp);
	}
}

int ifERROR(LISTE tete)
{
	while(tete && tete->val != -1) tete = tete->svt;
	if(tete) return 1;
	return 0;
}

int ifSAME(LISTE tete)
{
	LISTE p, j;
	for(p=tete;p;p=p->svt)
		for(j=tete;j != p;j=j->svt)
			if(j->val != p->val) return 0;
	return 1;
}		

int popListe(LISTE *tete)
{
	if(*tete){
		int x = (*tete)->val;
		*tete = (*tete)->svt;
		return x;
	}
	return 0;
}

// QUADRUPLET
typedef struct QUADRUPLET *QUADRUPLET;
struct QUADRUPLET
{
	char opr[100];
	char e1[100];
	char e2[100];
	char res[100];
	QUADRUPLET svt;
};

QUADRUPLET Quad(char* opr, char* e1, char* e2, char* res)
{
	QUADRUPLET p = malloc(sizeof(struct QUADRUPLET));
	strcpy(p->opr, opr);
	strcpy(p->e1, e1);
	strcpy(p->e2, e2);
	strcpy(p->res, res);
	p->svt = NULL;
	return p;
}

QUADRUPLET finQuad(QUADRUPLET tetq)
{
	while(tetq->svt) tetq = tetq->svt;
	return tetq;
}

void affQuad(QUADRUPLET tetq)
{
	int i, j;
	FILE *fich = fopen("QUAD.qc", "w+");
	char ch[50];
	
	fprintf(fich, "Les erreurs peuvent etre sur quadruplet a cause des erreurs sur votre code source !!!\n\n");
	for(i=1;tetq;i++,tetq=tetq->svt)
	{
		printf(" %d - (%s, %s, %s, %s)\n\n", i, tetq->opr, tetq->e1, tetq->e2, tetq->res);
		fprintf(fich, " %d - (%s, %s, %s, %s)\n\n", i, tetq->opr, tetq->e1, tetq->e2, tetq->res);
	}
	puts("Vous pouvez voir le quadruplet sue le fichier \"QUAD.qc\"");
	fclose(fich);
}

//liste pour sauvegarde les quadruplets pour faire apres MAJ

typedef struct sauv *SAVE;
struct sauv
{
	QUADRUPLET q;
	SAVE svt;
};

void addSave(SAVE *tets, QUADRUPLET q)
{
	SAVE p = malloc(sizeof(struct sauv));
	p->q = q;
	p->svt = *tets;
	*tets = p;
}

QUADRUPLET popSave(SAVE *tets)
{
	if(*tets){
		QUADRUPLET q = (*tets)->q;
		*tets = (*tets)->svt;
		return q;
	}
	return NULL;
}

// suavegarde les noms sur quadruplet

typedef struct elementch *LISTECH;
struct elementch
{
	char val[100];
	LISTECH svt;
};

void addCH(LISTECH *tete, char* val)
{
	LISTECH p = malloc(sizeof(struct elementch));
	strcpy(p->val, val);
	p->svt = *tete;
	*tete = p;
}

char* popCH(LISTECH *tete)
{
	char *val = NULL;
	if(*tete){ 
		val = strdup((*tete)->val);
		*tete = (*tete)->svt;
	}
	return val;
}

#endif // LISTE_H_INCLUDED
