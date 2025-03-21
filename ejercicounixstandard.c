/*
 * ejercicounixstandard.c
 * 
 * Copyright 2025 Emilio Muciño <emiliomucino@macbook-air-de-emilio.home>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 * 
 * 
 */


#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <stdlib.h>
int main(int argc, char **argv)
{
	/*
	pid_t pid;
	printf("Hola, Soy tu padre xd %d\n", getpid());
	int var1= 0, var2 = 0;
	pid = fork();
	
	if(pid >0){
		puts("Soy el proceso padre, quedo a la espera de que acabe el hijo");
		while(wait(NULL)>0){
			
		printf("La var1 es %d y la var2 es %d",var1 ,var2);
	}
	}else if (pid == 0)
	{
		
		printf("El proceso %d y mi padre es el proceso %d\n", getpid(), getppid());
		
		puts("Introduce un numero");
		scanf("%d",&var1);	
			
		puts("Introduce otro numero");
		scanf("%d",&var2);
		
		printf("La suma es %d\n", var1 + var2);
		printf("La resta es %d\n", var1 - var2);


		
		
		}
	*/
	
	
	int var1, var2;
	pid_t suma, resta;
	puts("Introduce un numero");
	scanf("%d",&var1);	
			
	puts("Introduce otro numero");
	scanf("%d",&var2);

		if((suma = fork())>0)
		{
			resta=fork();
			
			}
		if(suma ==0 && resta != 0){
			
			printf("Soy el proceso suma y la suma vale %d\n",var1 + var2);
		}
		else if (resta == 0)
		{
			printf("Soy el proceso resta y la resta vale %d\n",var1 - var2);
		}
		else //Proceso padre
		{
			while (wait(NULL)>0);
		}
	return 0;
}

