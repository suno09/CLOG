#ifndef PTS_H_INCLUDED
#define PTS_H_INCLUDED

typedef struct TS *PTS; //PTS => type pointeur de table de symbol
struct TS
{
	char nomE[100];
	char codE[100];
	char typeE[100];
	int taille, define, deb, fin;
	PTS svt;
};

#endif // PTS_H_INCLUDED