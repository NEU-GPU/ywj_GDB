//#pragma once
#include "cuda_runtime.h"
#include "device_launch_parameters.h"


#include <thrust/device_ptr.h>
#include <thrust/device_malloc.h>
#include <thrust/device_free.h>
#include <thrust/device_vector.h>

#include <stdio.h>
#include <string.h>
#include "malloc.h"
#include <iostream>
#include <stdlib.h>
//#include "head.h"


#define size1 10000000
#define No1 -1
int ex = 1;

int ndos = 0;
int pdos = 0;
int num_n = 0;
int num_r = 0;

char cc1[] = "[ ";
char cc2[] = " ]";
char cc3[] = " : ";
char cc4[] = "\n";
char cc5[] = "-";
char cc6[] = ">";

typedef struct Property Pro;

typedef struct Lab {
	char lab_key[20];
	char lab_value[20];
	Lab* nextlab;
}Lab;

typedef struct Node {
	char name[20];
	char label[20];
	int firstpro;
	int flag=0;
	int lab_num;
	Lab* lab = NULL;
}Node;
struct Property {
	char name[20];
	int  h;
	int  pre1;
	int  next1;
	int  l;
	int  pre2;
	int  next2;
	int  flag=0;
};
typedef struct Que {
	char str[20];
	int tol;
}Que;

Node* headnode = (Node*)malloc(sizeof(Node) * size1);
Pro* headpro = (Pro*)malloc(sizeof(Pro) * size1);

//thrust::host_vector<Node> headnode;
//thrust::host_vector<Pro> headpro;

//thrust::device_vector<Node> D_headnode;
//thrust::device_vector<Pro> D_headpro;

Node* D_headnode;
Pro* D_headpro;

void fileIO(char filename[]);
void createNode(char nodename[], char nodelabel[]);
int checkName(char nodename[]);
char* cypher(char* ch, int serve);
void createPro(char headname[], char lastname[], char proname[]);
int checkName(char nodename[]);
void And(int* A, int* B)
{
	int i = 0;
	while (i != ndos)
	{
		A[i] = A[i] & B[i];
		i++;
	}
}
void Or(int* A, int* B)
{
	int i = 0;
	while (i != ndos)
	{
		A[i] = A[i] | B[i];
		i++;
	}
}
void strc1(char str1[], char str2[]) {
	int len1 = sizeof(str1);
	int len2 = strlen(str2);
	int i = 0;
	while (i != len1)
	{
		str1[i] = '\0';
		i++;
	}
	i = 0;
	while (i != len2)
	{
		str1[i] = str2[i];
		i++;
	}
}

__device__ int Check(char a[], char b[]) {
	int i = 0;
	while (a[i] == b[i])
	{
		if (a[i] == '\0') {
			return 1;
		}
		i++;
	}
	return 0;
}

__device__ int copy(char a[],char b[]) 
{
	int i = 0;
	while (b[i]!='\0')
	{
		a[i] = b[i];
		i++;
	}
}
//
__global__ void D_checkName(int* D_ndos, Node* n_vec, char D_nodename[], int* D_lag)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_ndos)
	{
		if (Check(n_vec[i].name, D_nodename) && (n_vec[i].flag != 1)) {
			*D_lag = i;
		}
	}
}

__global__ void D_searchNode(int* D_ndos, Node* D_headnode, char D_nodename[], char D_nodelabel[], int* D_lag)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_ndos)
	{
		if (Check(D_headnode[i].name, D_nodename) && Check(D_headnode[i].label, D_nodelabel) && (D_headnode[i].flag != 1)) {
			*D_lag = i;
		}
	}
}

__global__ void D_searchPro_A(int* D_pdos, Pro* D_headpro, char D_proname[], int* D_lag, int* D_lag1)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].h == *D_lag1) && (D_headpro[i].flag != 1)) {
			D_lag[i] = 1;
		}
		else
		{
			D_lag[i] = No1;
		}
	}
}

__global__ void D_searchPro_B(int* D_pdos, Pro* D_headpro, char D_proname[], int* D_lag, int* D_lag1)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].l == *D_lag1) && (D_headpro[i].flag != 1)) {
			D_lag[i] = 1;
		}
		else
		{
			D_lag[i] = No1;
		}
	}
}

__global__ void D_searchPro_AB(int* D_pdos, Pro* D_headpro, char D_proname[], int* D_lag, int* D_lag1, int* D_lag2)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].h == *D_lag1) && (D_headpro[i].l == *D_lag2) && (D_headpro[i].flag != 1)) {
			D_lag[i] = 1;
		}
		else
		{
			D_lag[i] = No1;
		}
	}
}

__global__ void D_searchPro(int* D_pdos, Pro* D_headpro, char D_proname[], int* D_lag)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].flag != 1)) {
			D_lag[i] = 1;
		}
		else
		{
			D_lag[i] = No1;
		}
	}
}

__global__ void D_deleteNode(int* D_ndos, Node* D_headnode,Pro* D_headpro, char D_nodename[], char D_nodelabel[],int* D_num_r)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_ndos)
	{
		if (Check(D_headnode[i].name, D_nodename) && Check(D_headnode[i].label, D_nodelabel) && (D_headnode[i].flag != 1)) {
			D_headnode[i].flag = 1;
			if (D_headnode[i].firstpro != No1) {
				int j = D_headnode[i].firstpro;
				while (1) {
					if (i == D_headpro[j].h)
					{
						D_headpro[j].flag = 1;
						D_num_r--;
						j = D_headpro[j].next1;
						if (j == No1) {
							break;
						}
					}
					else
					{
						D_headpro[j].flag = 1;
						D_num_r--;
						j = D_headpro[j].next2;
						if (j == No1) {
							break;
						}
					}
				}
			}
		}
	}
}

__global__ void D_deletePro_AB(int* D_pdos, Pro* D_headpro, char D_proname[],  int* D_lag1, int* D_lag2, int* D_num_r)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].h == *D_lag1) && (D_headpro[i].l == *D_lag2) && (D_headpro[i].flag != 1)) {
			D_headpro[i].flag = 1;
			D_num_r--;
		}
	}
}

__global__ void D_deletePro_A(int* D_pdos, Pro* D_headpro, char D_proname[], int* D_lag1, int* D_num_r)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].h == *D_lag1) && (D_headpro[i].flag != 1)) {
			D_headpro[i].flag = 1;
			D_num_r--;
		}
	}
}

__global__ void D_deletePro_B(int* D_pdos, Pro* D_headpro, char D_proname[], int* D_lag1, int* D_num_r)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].l == *D_lag1) && (D_headpro[i].flag != 1)) {
			D_headpro[i].flag = 1;
			D_num_r--;
		}
	}
}

__global__ void D_deletePro(int* D_pdos, Pro* D_headpro, char D_proname[], int* D_num_r)
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].flag != 1)) {
			D_headpro[i].flag = 1;
			D_num_r--;
		}
	}
}

__global__ void D_updateProname_AB(int* D_pdos, Pro* D_headpro, char D_proname[], int* D_lag1, int* D_lag2,char D_newname[])
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].h == *D_lag1) && (D_headpro[i].l == *D_lag2) && (D_headpro[i].flag != 1)) {
			copy(D_headpro[i].name,D_newname);
		}
	}
}

__global__ void D_updateProname_A(int* D_pdos, Pro* D_headpro, char D_proname[], int* D_lag1, char D_newname[]) 
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].h == *D_lag1) && (D_headpro[i].flag != 1)) {
			copy(D_headpro[i].name, D_newname);
		}
	}
}

__global__ void D_updateProname_B(int* D_pdos, Pro* D_headpro, char D_proname[], int* D_lag1, char D_newname[]) 
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].l == *D_lag1) && (D_headpro[i].flag != 1)) {
			copy(D_headpro[i].name, D_newname);
		}
	}
}

__global__ void D_updateProname(int* D_pdos, Pro* D_headpro, char D_proname[],  char D_newname[])
{
	int i = threadIdx.x + blockIdx.x * blockDim.x;
	if (i < *D_pdos) {
		if (Check(D_headpro[i].name, D_proname) && (D_headpro[i].flag != 1)) {
			copy(D_headpro[i].name, D_newname);
		}
	}
}
void createproperty(int i, char labelkey[], char labelvalue[])
{
	Lab newlab;
	strc1(newlab.lab_key, labelkey);
	strc1(newlab.lab_value, labelvalue);
	if (headnode[i].lab==NULL)
	{
		headnode[i].lab = &newlab;
	}
	else
	{
		Lab* next = headnode[i].lab;
		if (strcmp(next->lab_key, labelkey) == 0)
		{
			printf("label already exsit!\n");
				return;
		}
		while (next->nextlab!=NULL)
		{
			next = next->nextlab;
			if (strcmp(next->lab_key, labelkey) == 0)
			{
				printf("label already exsit!\n");
				return;
			}
		}
		(*next).nextlab = &newlab;
	}
	//Lab* head = headnode[i].lab;
	/*Lab* next = headnode[i].lab;;
	while (next != NULL)
	{
		if (strcmp(next->lab_key, labelkey) == 0)
		{
			printf("label already exsit!\n");
			return;
		}
		next = next->nextlab;
	}
	next = &newlab;*/
	headnode[i].lab_num++;
}

void deleleproperty(int i,char labelkey[]) 
{
	if (i==No1)
	{
		printf("no that node!\n");
		return;
	}
	
	if (headnode[i].lab_num==0)
	{
		printf("no that property!\n");
	}
	else if (headnode[i].lab_num == 1)
	{
		if (strcmp(headnode[i].lab->lab_key, labelkey) == 0)
		{
			headnode[i].lab = NULL;
			headnode[i].lab_num--;
			return;
		}
		else
		{
			printf("no that property!\n");
		}
	}
	else
	{
		if (strcmp(headnode[i].lab->lab_key, labelkey) == 0)
		{
			headnode[i].lab = headnode[i].lab->nextlab;
			headnode[i].lab_num--;
			return;
		}
		Lab* head = headnode[i].lab;
		Lab* next = head->nextlab;
		while (next != NULL)
		{
			if (strcmp(next->lab_key, labelkey) == 0)
			{
				(*head).nextlab = (*next).nextlab;
				headnode[i].lab_num--;
				return;
			}
		}
	}
	
}

void Data_createPro(char headname[], char lastname[], char proname[])
{
	printf("ndos: %d\n", ndos);
	printf("headname: %s\t lastname: %s ", headname, lastname);
	headpro[pdos].h = No1;
	headpro[pdos].l = No1;
	headpro[pdos].next1 = No1;
	headpro[pdos].next2 = No1;
	headpro[pdos].pre1 = No1;
	headpro[pdos].pre2 = No1;
	headpro[pdos].flag = 0;
	strc1(headpro[pdos].name, proname);
	/*Pro pro;
	pro.l = No1;
	pro.h = No1;
	pro.next1 = No1;
	pro.next2 = No1;
	pro.pre1 = No1;
	pro.pre2 = No1;
	pro.flag = 0;
	strc1(pro.name, proname);
	headpro.push_back(pro);*/
	//D_headpro.push_back(pro);
	int last, head;
	last = checkName(lastname);
	head = checkName(headname);
	printf("check:%d,%d\n", head, last);
	//printf("yyyyyyyyyyyyyyyyyy\n");
	if ((head == No1) && (last == No1)) {
		createNode(headname, headname);
		createNode(lastname, lastname);
		last = (ndos - 1);
		head = (ndos - 2);
		//printf("9999999999999999\n");
	}
	else if (head == No1) {
		createNode(headname, headname);
		head = (ndos - 1);
		//printf("qqqqqqqqqqqqqq\n");
	}
	else if (last == No1) {
		createNode(lastname, lastname);
		last = (ndos - 1);
		//printf("wwwwwwwwwwwww\n");
	}
	//printf("9zzzzzzzzzz9\n");
	headpro[pdos].h = head;
	if (headnode[head].firstpro == No1)     //Éú³ÉÊ®×ÖÁ´±í
	{
		headnode[head].firstpro = pdos;
	}
	else
	{
		int pi = headnode[head].firstpro;
		int lag = 0;
		while (1)
		{

			if (headpro[pi].h == head)
			{
				if (headpro[pi].next1 == No1)
				{
					headpro[pi].next1 = pdos;
					headpro[pdos].pre1 = pi;
					break;
				}
				pi = headpro[pi].next1;
			}
			else
			{
				if (headpro[pi].next2 == No1)
				{
					headpro[pi].next2 = pdos;
					headpro[pdos].pre1 = pi;
					break;
				}
				pi = headpro[pi].next2;
			}
		}
	}
	headpro[pdos].l = last;
	if (headnode[last].firstpro == No1)
	{
		headnode[last].firstpro = pdos;
	}
	else
	{
		int pi = headnode[last].firstpro;
		int lag = 0;
		while (1)
		{
			if (headpro[pi].h == last)
			{
				if (headpro[pi].next1 == No1)
				{
					headpro[pi].next1 = pdos;
					headpro[pdos].pre2 = pi;
					break;
				}
				pi = headpro[pi].next1;
			}
			else
			{
				if (headpro[pi].next2 == No1)
				{
					headpro[pi].next2 = pdos;
					headpro[pdos].pre2 = pi;
					break;
				}
				pi = headpro[pi].next2;
			}
		}
	}
	pdos++;
	num_r++;

}

void Data_createNode(char nodename[], char labelname[]) 
{
	/*Node node;
	node.firstpro = No1;
	node.flag = 0;
	strc1(node.label, labelname);
	strc1(node.name, nodename);
	headnode.push_back(node);*/
	printf("1111111111111111111111!");
	headnode[ndos].firstpro = No1;
	headnode[ndos].flag = 0;
	headnode[ndos].lab = NULL;
	headnode[ndos].lab_num = 0;
	strc1(headnode[ndos].name, nodename);
	strc1(headnode[ndos].label, labelname);
	ndos++;
	printf("ndos: %d", ndos);
	num_n++;
}

void Datainsert(char node_filename[], char pro_filename[])     //读学姐得数据集  名字和标签为同值，没有特征。
{
	FILE* fn;
	ndos = 0;
	num_n = 0;
	int i = 0;
	int j = 0;
	//fopen_s(&fn, node_filename, "r");
	fn=fopen(node_filename, "r");
	while (!feof(fn))
	{
		int head;
		char headname[20];
		fscanf(fn, "%s\n", headname);
		//sprintf_s(headname, "%d", head);
		Data_createNode(headname, headname);

		printf("nodeline: %d\n", i);
		i++;
	}
	fclose(fn);
	printf("insert node success!!!");
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	//D_headnode = headnode;
	//
	
	FILE* fp;
	pdos = 0;
	num_r = 0;
	//std::string filename = "C:\\Users\\YuWenJian\\Desktop\\task+++";
	//fopen_s(&fp, pro_filename, "r");
	fp=fopen(pro_filename, "r");
	while (!feof(fp))
	{
		int head, last, pro;
		char headname[20], lastname[20], proname[20];
		fscanf(fp, "%s", headname);
		fscanf(fp, "%s", lastname);
		fscanf(fp, "%s", proname);
		//sprintf_s(headname, "%d", head);
		//sprintf_s(lastname, "%d", last);
		//sprintf_s(proname, "%d", pro);
		createPro(headname, lastname, proname);

		printf("proine: %d\n", j);
		j++;
	}

	fclose(fp);
	//D_headnode = headnode;
	//D_headpro = headpro;
	printf("insert pro success!!!");
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
}
	

 

void Datastore(char filename1[],char filename2[])
{
	FILE* fn;
	//if ((fn = fopen(filename1, "w")) != NULL)
	//fopen_s(&fn, filename1, "w");
	fn=fopen(filename1, "w");
	int i = 0;
	while (i != ndos)
	{
		if (headnode[i].flag==0)
		{
			//fprintf(fn, "");
			fprintf(fn, "%s\t%s\t%d\t", headnode[i].name,headnode[i].label, headnode[i].lab_num);

		}
		int j = 0;
		Lab* lab=headnode[i].lab;
		while (j < headnode[i].lab_num)
		{
			fprintf(fn, "%s\t%s\t", lab->lab_key,lab->lab_value);
			lab = lab->nextlab;
			j++;
		}
		fprintf(fn, "\n");
		i++;
	}
	fclose(fn);
	ndos = 0;
	num_n = 0;
	FILE* fp;
	//if ((fn = fopen(filename1, "w")) != NULL)
	fp=fopen( filename2, "w");
	i = 0;
	while (i != pdos)
	{
		if (headpro[i].flag == 0)
		{
			fprintf(fn, "%s\t%s\t%s\n", headnode[headpro[i].h],headnode[headpro[i].l], headpro[i].name);
		}
		i++;
	}
	fclose(fp);
	pdos = 0;
	num_r = 0;
}

void Dataload(char filename1[],char filename2[])
{
	FILE* fn;
	ndos = 0;
	num_n = 0;
	int i = 0;
	int j = 0;
	//fopen_s(&fn, filename1, "r");
	fn=fopen( filename1, "r");
	while (!feof(fn))
	{
		char headname[20];
		char labelname[20];
		int tmp=0;

		fscanf(fn, "%s\t", headname);
		//fscanf_s(fn,"%d",)
		//Lab lab;
		fscanf(fn, "%s\t", labelname);
		//sprintf_s(headname, "%d", head);
		fscanf(fn, "%d\t", &tmp);
		Data_createNode(headname, headname);
		headnode[(ndos-1)].lab_num = tmp;
		//printf("tmp:  %d   headnode[--ndos].lab_num:   %d",tmp,  headnode[(ndos-1)].lab_num);
		int n = 0;
		while (n<headnode[(ndos-1)].lab_num)
		{
			char a[20],b[20];
			fscanf(fn, "%s\t", a);
			fscanf(fn, "%s\t", b);
			createproperty((ndos-1),a,b);
			n++;
			
		}
		printf("nodeline: %d\n", i);
		i++;
	}
	fclose(fn);
	//D_headnode = headnode;
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	//
	printf("ndos:   %d",ndos);
	printf("insert node success!!!");
	FILE* fp;
	pdos = 0;
	num_r = 0;
	//std::string filename = "C:\\Users\\YuWenJian\\Desktop\\task+++";
	//fopen_s(&fp, filename2, "r");
	fp=fopen(filename2, "r");
	while (!feof(fp))
	{
		//int head, last, pro;
		char headname[20], lastname[20], proname[20];
		fscanf(fp, "%s\t", headname);
		fscanf(fp, "%s\t", lastname);
		fscanf(fp, "%s\n", proname);
		//sprintf_s(headname, "%d", head);
		//sprintf_s(lastname, "%d", last);
		//sprintf_s(proname, "%d", pro);
		Data_createPro(headname, lastname, proname);

		printf("proine: %d\n", j);
		j++;

	}
	fclose(fp);
	//D_headnode = headnode;
	//D_headpro = headpro;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	printf("insert pro success!!!");
}
void SubgraphIso()
{

}

void  createNode(char nodename[], char nodelabel[])
{
	if (checkName(nodename)!=No1)
	{
		printf("you need change a name\n");
		return;
	}
	headnode[ndos].firstpro = No1;
	headnode[ndos].flag = 0;
	headnode[ndos].lab_num = 0;
	headnode[ndos].lab = NULL;
	strc1(headnode[ndos].name, nodename);
	strc1(headnode[ndos].label, nodelabel);
	ndos++;
	num_n++;
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	//printf("wwwwwwwwwwwwwwww\n");
	//headnode.push_back(node);
	//printf("jjjjjjjjjjjjjjjj\n");
	//D_headnode = headnode;
	//thrust::fill(codes.begin(), codes.end(), 1);
	//printf("qqqqqqqqqqqqqqqqqqq\n");
	//ndos++;
	//num_n++;
	/*Node node;
	node.firstpro = No1;
	node.flag = 0;
	strc1(node.name, nodename);
	strc1(node.label, nodelabel);
	*/
}
void createPro(char headname[], char lastname[], char proname[])
{
	headpro[pdos].h = No1;
	headpro[pdos].l = No1;
	headpro[pdos].next1 = No1;
	headpro[pdos].next2 = No1;
	headpro[pdos].pre1 = No1;
	headpro[pdos].pre2 = No1;
	headpro[pdos].flag = 0;
	strc1(headpro[pdos].name, proname);
		/*
	Pro pro;
	pro.l = No1;
	pro.next1 = No1;
	pro.next2 = No1;
	pro.pre1 = No1;
	pro.pre2 = No1;
	pro.flag = 0;
	strc1(pro.name, proname);
	headpro.push_back(pro);*/
	//D_headpro.push_back(pro);
	int last, head;
	last = checkName(lastname);
	head = checkName(headname);
	printf("check:%d,%d\n", head, last);
	//printf("yyyyyyyyyyyyyyyyyy\n");
	if ((head == No1) && (last == No1)) {
		createNode(headname, headname);
		createNode(lastname, lastname);
		last = (ndos - 1);
		head = (ndos - 2);
		//printf("9999999999999999\n");
	}
	else if (head == No1) {
		createNode(headname, headname);
		head = (ndos - 1);
		//printf("qqqqqqqqqqqqqq\n");
	}
	else if (last == No1) {
		createNode(lastname, lastname);
		last = (ndos - 1);
		//printf("wwwwwwwwwwwww\n");
	}
	//printf("9zzzzzzzzzz9\n");
	headpro[pdos].h = head;
	if (headnode[head].firstpro == No1)     //Éú³ÉÊ®×ÖÁ´±í
	{
		headnode[head].firstpro = pdos;
	}
	else
	{
		int pi = headnode[head].firstpro;
		int lag = 0;
		while (1)
		{

			if (headpro[pi].h == head)
			{
				if (headpro[pi].next1 == No1)
				{
					headpro[pi].next1 = pdos;
					headpro[pdos].pre1 = pi;
					break;
				}
				pi = headpro[pi].next1;
			}
			else
			{
				if (headpro[pi].next2 == No1)
				{
					headpro[pi].next2 = pdos;
					headpro[pdos].pre1 = pi;
					break;
				}
				pi = headpro[pi].next2;
			}
		}
	}
	headpro[pdos].l = last;
	if (headnode[last].firstpro == No1)
	{
		headnode[last].firstpro = pdos;
	}
	else
	{
		int pi = headnode[last].firstpro;
		int lag = 0;
		while (1)
		{
			if (headpro[pi].h == last)
			{
				if (headpro[pi].next1 == No1)
				{
					headpro[pi].next1 = pdos;
					headpro[pdos].pre2 = pi;
					break;
				}
				pi = headpro[pi].next1;
			}
			else
			{
				if (headpro[pi].next2 == No1)
				{
					headpro[pi].next2 = pdos;
					headpro[pdos].pre2 = pi;
					break;
				}
				pi = headpro[pi].next2;
			}
		}
	}

	pdos++;
	num_r++;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
}

int checkName(char nodename[])                //Nodes with the same name are not allowed 
{
	int* lag = (int*)malloc(sizeof(int));
	*lag = -1;
	int* D_lag, * D_ndos;
	char* D_nodename;
	cudaMalloc((void**)&D_ndos, sizeof(int));
	cudaMalloc((void**)&D_lag, sizeof(int));
	cudaMalloc((void**)&D_nodename, sizeof(char) * 20);
	
	cudaMemcpy(D_nodename, nodename, sizeof(char) * 20, cudaMemcpyHostToDevice);
	
	cudaMemcpy(D_lag, lag, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_ndos, &ndos, sizeof(int), cudaMemcpyHostToDevice);
	//printf("77777777777777\n");
	int blocksize;
	int gridsize;
	if (ndos < 512)
	{
		blocksize = ndos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (ndos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);

	//Node* n_vec = thrust::raw_pointer_cast(D_headnode.data());
	//
	D_checkName << <dimGrid, dimBlock >> > (D_ndos, D_headnode, D_nodename, D_lag);
	//printf("88888888888888888888\n");
	cudaMemcpy(lag, D_lag, sizeof(int), cudaMemcpyDeviceToHost);

	cudaFree(D_lag);
	cudaFree(D_ndos);
	cudaFree(D_nodename);
	//cudaFree(D_headnode);
	//printf("9999999999999999\n");
	return *lag;
}  


int Searchnode(char nodename[], char nodelabel[])    //cuda c 
{
	int* lag = (int*)malloc(sizeof(int));
	//int* lag = nullptr;
	*lag = -1;
	int* D_lag, * D_ndos;
	char* D_nodename;
	char* D_nodelabel;
	cudaMalloc((void**)&D_lag, sizeof(int));
	cudaMalloc((void**)&D_ndos, sizeof(int));
	cudaMalloc((void**)&D_nodename, sizeof(char) * 20);
	cudaMalloc((void**)&D_nodelabel, sizeof(char) * 20);
	//cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_nodename, nodename, sizeof(char) * 20, cudaMemcpyHostToDevice);
	cudaMemcpy(D_nodelabel, nodelabel, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag, lag, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_ndos, &ndos, sizeof(int), cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (ndos < 516)
	{
		blocksize = ndos;
		gridsize = 1;
	}
	else
	{
		blocksize = 516;
		gridsize = (ndos + 515) / 516;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);
	//Node* n_vec = thrust::raw_pointer_cast(D_headnode.data());
	D_searchNode << <dimGrid, dimBlock >> > (D_ndos, D_headnode, D_nodename, D_nodelabel, D_lag);
	cudaMemcpy(lag, D_lag, sizeof(int), cudaMemcpyDeviceToHost);

	cudaFree(D_lag);
	cudaFree(D_ndos);
	cudaFree(D_nodename);
	cudaFree(D_nodelabel);
	//cudaFree(D_headnode);

	return *lag;
	//return 1;
}

void SearchPro_AB(int pro[], char proname[], char A[], char B[])            //cuda c
{
	int* lag_1 = (int*)malloc(sizeof(int));
	*lag_1 = checkName(A);
	int* lag_2 = (int*)malloc(sizeof(int));
	*lag_2 = checkName(B);
	int* D_lag1;
	int* D_lag2;
	int* D_pdos;
	cudaMalloc((void**)&D_lag1, sizeof(int));
	cudaMalloc((void**)&D_lag2, sizeof(int));
	cudaMalloc((void**)&D_pdos, sizeof(int));
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	int* D_lag;
	char* D_proname;
	cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag1, lag_1, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag2, lag_2, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);

	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_searchPro_AB << <dimGrid, dimBlock >> > (D_pdos,D_headpro, D_proname, D_lag, D_lag1, D_lag2);
	cudaMemcpy(pro, D_lag, sizeof(int) * pdos, cudaMemcpyDeviceToHost);
	cudaFree(D_lag);
	cudaFree(D_lag1);
	cudaFree(D_lag2);
	cudaFree(D_pdos);
	cudaFree(D_proname);
	//cudaFree(D_headpro);
}
void SearchPro_A(int pro[], char proname[], char A[])                          //cuda c
{
	int* lag_1 = (int*)malloc(sizeof(int));
	*lag_1 = checkName(A);
	int* D_lag1;
	cudaMalloc((void**)&D_lag1, sizeof(int));
	int* D_lag;
	char* D_proname;
	cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag1, lag_1, sizeof(int), cudaMemcpyHostToDevice);
	int* D_pdos;
	cudaMalloc((void**)&D_pdos, sizeof(int));
	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);
	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_searchPro_A << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname, D_lag, D_lag1);
	cudaMemcpy(pro, D_lag, sizeof(int) * pdos, cudaMemcpyDeviceToHost);
	cudaFree(D_lag);
	cudaFree(D_lag1);
	//cudaFree(D_lag2);
	cudaFree(D_pdos);
	cudaFree(D_proname);
	//cudaFree(D_headpro);
}
void SearchPro_B(int pro[], char proname[], char B[])                           //cuda c
{
	int* lag_1 = (int*)malloc(sizeof(int));
	*lag_1 = checkName(B);
	int* D_lag1;
	cudaMalloc((void**)&D_lag1, sizeof(int));
	int* D_lag;
	char* D_proname;
	cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag1, lag_1, sizeof(int), cudaMemcpyHostToDevice);
	int* D_pdos;
	cudaMalloc((void**)&D_pdos, sizeof(int));
	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);
	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_searchPro_B << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname, D_lag, D_lag1);
	cudaMemcpy(pro, D_lag, sizeof(int) * pdos, cudaMemcpyDeviceToHost);
	cudaFree(D_lag);
	cudaFree(D_lag1);
	//cudaFree(D_lag2);
	cudaFree(D_pdos);
	cudaFree(D_proname);
	//cudaFree(D_headpro);
}
void SearchPro(int pro[], char proname[])               //cuda c
{
	int* D_lag;
	char* D_proname;
	cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);
	int* D_pdos;
	cudaMalloc((void**)&D_pdos, sizeof(int));
	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);
	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_searchPro << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname, D_lag);
	cudaMemcpy(pro, D_lag, sizeof(int) * pdos, cudaMemcpyDeviceToHost);
	cudaFree(D_lag);
	//cudaFree(D_lag1);
	//cudaFree(D_lag2);
	cudaFree(D_pdos);
	cudaFree(D_proname);
	//cudaFree(D_headpro);
}

void Deletnode(char nodename[], char nodelabel[])
{
	int* D_ndos;
	char* D_nodename;
	char* D_nodelabel;
	int* D_num_r;
	cudaMalloc((void**)&D_num_r, sizeof(int));
	cudaMalloc((void**)&D_ndos, sizeof(int));
	cudaMalloc((void**)&D_nodename, sizeof(char) * 20);
	cudaMalloc((void**)&D_nodelabel, sizeof(char) * 20);
	//cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_nodename, nodename, sizeof(char) * 20, cudaMemcpyHostToDevice);
	cudaMemcpy(D_nodelabel, nodelabel, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_ndos, &ndos, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_num_r, &num_r, sizeof(int), cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (ndos < 516)
	{
		blocksize = ndos;
		gridsize = 1;
	}
	else
	{
		blocksize = 516;
		gridsize = (ndos + 515) / 516;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);
	//Node* n_vec = thrust::raw_pointer_cast(D_headnode.data());
	D_deleteNode << <dimGrid, dimBlock >> > (D_ndos, D_headnode, D_headpro, D_nodename, D_nodelabel,D_num_r);
	cudaMemcpy(headpro, D_headpro, sizeof(Pro) * pdos, cudaMemcpyDeviceToHost);
	cudaMemcpy(headnode, D_headnode, sizeof(Node) * ndos, cudaMemcpyDeviceToHost);
	cudaMemcpy(&num_r, D_num_r, sizeof(int), cudaMemcpyDeviceToHost);
	num_n--;
	cudaFree(D_num_r);
	cudaFree(D_ndos);
	cudaFree(D_nodename);
	cudaFree(D_nodelabel);
}
/*void Deletenode(char nodename[], char nodelabel[])
{
	int lag = Searchnode(nodename, nodelabel);
	headnode[lag].flag = 1;
	if (headnode[lag].firstpro != No1) {
		int j = headnode[lag].firstpro;
		while (1) {
			if (lag == headpro[j].h)
			{
				headpro[j].flag = 1;
				num_r--;
				j = headpro[j].next1;
				if (j == No1) {
					break;
				}
			}
			else
			{
				headpro[j].flag = 1;
				num_r--;
				j = headpro[j].next2;
				if (j == No1) {
					break;
				}
			}
		}
	}
	num_n--;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
}
*/
void DeletPro_AB(int pro[], char proname[], char A[], char B[])
{

	/*SearchPro_AB(pro, proname, A, B);
	int i = 0;
	while (i != pdos)
	{
		if (pro[i] == 1)
		{
			headpro[i].flag = 1;
		}
		i++;
	}
	num_r--;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	*/
	int* lag_1 = (int*)malloc(sizeof(int));
	*lag_1 = checkName(A);
	int* lag_2 = (int*)malloc(sizeof(int));
	*lag_2 = checkName(B);
	int* D_lag1;
	int* D_lag2;
	int* D_pdos;
	
	cudaMalloc((void**)&D_lag1, sizeof(int));
	cudaMalloc((void**)&D_lag2, sizeof(int));
	cudaMalloc((void**)&D_pdos, sizeof(int));
	
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	//int* D_lag;
	char* D_proname;
	//cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag1, lag_1, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag2, lag_2, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	int* D_num_r;
	cudaMalloc((void**)&D_num_r, sizeof(int));
	cudaMemcpy(D_num_r, &num_r, sizeof(int), cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);

	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_deletePro_AB << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname,  D_lag1, D_lag2, D_num_r);
	cudaMemcpy(headpro, D_headpro, sizeof(Pro) * pdos, cudaMemcpyDeviceToHost);
	cudaMemcpy(&num_r,D_num_r,sizeof(int), cudaMemcpyDeviceToHost);
	cudaFree(D_num_r);
	cudaFree(D_lag1);
	cudaFree(D_lag2);
	cudaFree(D_pdos);
	cudaFree(D_proname);
}
void DeletPro_A(int pro[], char proname[], char A[])
{
	/*SearchPro_A(pro, proname, A);
	int i = 0;
	while (i != pdos)
	{
		if (pro[i] == 1)
		{
			headpro[i].flag = 1;
		}
		i++;
	}
	num_r--;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	*/
	int* lag_1 = (int*)malloc(sizeof(int));
	*lag_1 = checkName(A);
	int* D_lag1;
	int* D_pdos;
	cudaMalloc((void**)&D_lag1, sizeof(int));
	cudaMalloc((void**)&D_pdos, sizeof(int));
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	//int* D_lag;
	char* D_proname;
	//cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag1, lag_1, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	int* D_num_r;
	cudaMalloc((void**)&D_num_r, sizeof(int));
	cudaMemcpy(D_num_r, &num_r, sizeof(int), cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);

	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_deletePro_A << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname, D_lag1, D_num_r);
	cudaMemcpy(headpro, D_headpro, sizeof(Pro) * pdos, cudaMemcpyDeviceToHost);
	cudaMemcpy(&num_r, D_num_r, sizeof(int), cudaMemcpyDeviceToHost);

	cudaFree(D_num_r);
	cudaFree(D_lag1);
	cudaFree(D_pdos);
	cudaFree(D_proname);
}
void DeletPro_B(int pro[], char proname[], char B[])
{
	/*SearchPro_B(pro, proname, B);
	int i = 0;
	while (i != pdos)
	{
		if (pro[i] == 1)
		{
			headpro[i].flag = 1;
		}
		i++;
	}
	num_r--;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	*/
	int* lag_1 = (int*)malloc(sizeof(int));
	*lag_1 = checkName(B);
	int* D_lag1;
	int* D_pdos;
	cudaMalloc((void**)&D_lag1, sizeof(int));
	cudaMalloc((void**)&D_pdos, sizeof(int));
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	//int* D_lag;
	char* D_proname;
	//cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag1, lag_1, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	int* D_num_r;
	cudaMalloc((void**)&D_num_r, sizeof(int));
	cudaMemcpy(D_num_r, &num_r, sizeof(int), cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);

	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_deletePro_B << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname, D_lag1, D_num_r);
	cudaMemcpy(headpro, D_headpro, sizeof(Pro) * pdos, cudaMemcpyDeviceToHost);
	cudaMemcpy(&num_r, D_num_r, sizeof(int), cudaMemcpyDeviceToHost);
	cudaFree(D_num_r);
	cudaFree(D_lag1);
	cudaFree(D_pdos);
	cudaFree(D_proname);
}
void DeletPro(int pro[], char proname[])
{
	/*SearchPro(pro, proname);
	int i = 0;
	while (i != pdos)
	{
		if (pro[i] == 1)
		{
			headpro[i].flag = 1;
		}
		i++;
	}
	num_r--;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	*/
	char* D_proname;
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	int* D_pdos;
	cudaMalloc((void**)&D_pdos, sizeof(int));
	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	int* D_num_r;
	cudaMalloc((void**)&D_num_r, sizeof(int));
	cudaMemcpy(D_num_r, &num_r, sizeof(int), cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);
	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_deletePro << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname, D_num_r);
	cudaMemcpy(&num_r, D_num_r, sizeof(int), cudaMemcpyDeviceToHost);
	cudaFree(D_num_r);
	cudaFree(D_pdos);
	cudaFree(D_proname);
}
void renew()
{
	char name1[] = "tmp_file1";
	char name2[] = "tmp_file2";
	Datastore(name1,name2);
	Dataload(name1,name2);
	remove(name1);
	remove(name2);
}
void updatenodename(char nodename[], char newname[])
{
	int lag = checkName(nodename);
	int lag1= checkName(newname);
	if (lag==No1)
	{
		printf("This Node not exist!");
		return;
	}
	if (lag1!=No1)
	{
		printf("new name has ready exist!");
		return;
	}
	strc1(headnode[lag].name, newname);
	strc1(headnode[lag].label, newname);
	//cudaMalloc((void**)&D_headnode, sizeof(Node) * ndos);
	cudaMemcpy(D_headnode, headnode, sizeof(Node) * ndos, cudaMemcpyHostToDevice);
	//D_headpro = headpro;
}
void updateProname_AB(char proname[], char A[], char B[], char newname[])
{
	char* D_newname;

	/*int* pro = (int*)malloc(sizeof(int) * pdos);
	SearchPro_AB(pro, proname, A, B);
	int i = 0;
	while (i != pdos)
	{
		if (pro[i] == 1)
		{
			strc1(headpro[i].name, newname);
		}
		i++;
	}
	//D_headnode = headnode;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	*/
	int* lag_1 = (int*)malloc(sizeof(int));
	*lag_1 = checkName(A);
	int* lag_2 = (int*)malloc(sizeof(int));
	*lag_2 = checkName(B);
	int* D_lag1;
	int* D_lag2;
	int* D_pdos;
	cudaMalloc((void**)&D_lag1, sizeof(int));
	cudaMalloc((void**)&D_lag2, sizeof(int));
	cudaMalloc((void**)&D_pdos, sizeof(int));
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	//int* D_lag;
	char* D_proname;
	//cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_newname, sizeof(char) * 20);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag1, lag_1, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag2, lag_2, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_newname, newname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);

	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_updateProname_AB << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname, D_lag1, D_lag2,D_newname);
	cudaMemcpy(headpro, D_headpro, sizeof(Pro) * pdos, cudaMemcpyDeviceToHost);
	cudaFree(D_newname);
	cudaFree(D_lag1);
	cudaFree(D_lag2);
	cudaFree(D_pdos);
	cudaFree(D_proname);
}
void updateProname_A(char proname[], char A[], char newname[])
{
	char* D_newname;
	/*int* pro = (int*)malloc(sizeof(int) * pdos);
	SearchPro_A(pro, proname, A);
	int i = 0;
	while (i != pdos)
	{
		if (pro[i] == 1)
		{
			strc1(headpro[i].name, newname);
		}
		i++;
	}
	//D_headnode = headnode;
	//D_headpro = headpro;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	*/
	int* lag_1 = (int*)malloc(sizeof(int));
	*lag_1 = checkName(A);
	int* D_lag1;
	int* D_pdos;
	cudaMalloc((void**)&D_lag1, sizeof(int));
	cudaMalloc((void**)&D_pdos, sizeof(int));
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	//int* D_lag;
	char* D_proname;
	//cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_newname, sizeof(char) * 20);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag1, lag_1, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_newname, newname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);

	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_updateProname_A << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname, D_lag1,  D_newname);
	cudaMemcpy(headpro, D_headpro, sizeof(Pro) * pdos, cudaMemcpyDeviceToHost);

	cudaFree(D_newname);
	cudaFree(D_lag1);
	cudaFree(D_pdos);
	cudaFree(D_proname);
}
void updateProname_B(char proname[], char B[], char newname[])
{
	char* D_newname;
	/*
	int* pro = (int*)malloc(sizeof(int) * pdos);
	SearchPro_B(pro, proname, B);
	int i = 0;
	while (i != pdos)
	{
		if (pro[i] == 1)
		{
			strc1(headpro[i].name, newname);
		}
		i++;
	}
	//D_headnode = headnode;
	//D_headpro = headpro;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	*/
	int* lag_1 = (int*)malloc(sizeof(int));
	*lag_1 = checkName(B);
	int* D_lag1;
	int* D_pdos;
	cudaMalloc((void**)&D_lag1, sizeof(int));

	cudaMalloc((void**)&D_pdos, sizeof(int));
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	//int* D_lag;
	char* D_proname;
	//cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_newname, sizeof(char) * 20);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);
	cudaMemcpy(D_lag1, lag_1, sizeof(int), cudaMemcpyHostToDevice);

	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_newname, newname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);

	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_updateProname_B << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname, D_lag1,  D_newname);
	cudaMemcpy(headpro, D_headpro, sizeof(Pro) * pdos, cudaMemcpyDeviceToHost);
	cudaFree(D_newname);
	cudaFree(D_lag1);
	cudaFree(D_pdos);
	cudaFree(D_proname);
}
void updateProname(char proname[], char newname[])
{
	char* D_newname;
	/*
	int* pro = (int*)malloc(sizeof(int) * pdos);
	SearchPro(pro, proname);
	int i = 0;
	while (i != pdos)
	{
		if (pro[i] == 1)
		{
			strc1(headpro[i].name, newname);
		}
		i++;
	}
	//D_headnode = headnode;
	//D_headpro = headpro;
	cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	*/
	int* D_pdos;
	cudaMalloc((void**)&D_pdos, sizeof(int));
	//cudaMalloc((void**)&D_headpro, sizeof(Pro) * pdos);
	//int* D_lag;
	char* D_proname;
	//cudaMalloc((void**)&D_lag, sizeof(int) * pdos);
	cudaMalloc((void**)&D_newname, sizeof(char) * 20);
	cudaMalloc((void**)&D_proname, sizeof(char) * 20);
	cudaMemcpy(D_proname, proname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_headpro, headpro, sizeof(Pro) * pdos, cudaMemcpyHostToDevice);
	//cudaMemcpy(D_lag, pro, sizeof(int) * pdos, cudaMemcpyHostToDevice);

	cudaMemcpy(D_pdos, &pdos, sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(D_newname, newname, sizeof(char) * 20, cudaMemcpyHostToDevice);
	int blocksize;
	int gridsize;
	if (pdos < 512)
	{
		blocksize = pdos;
		gridsize = 1;
	}
	else
	{
		blocksize = 128;
		gridsize = (pdos + 127) / 128;
	}
	dim3 dimBlock(blocksize);
	dim3 dimGrid(gridsize);

	//Pro* p_vec = thrust::raw_pointer_cast(D_headpro.data());
	D_updateProname << <dimGrid, dimBlock >> > (D_pdos, D_headpro, D_proname, D_newname);
	cudaMemcpy(headpro, D_headpro, sizeof(Pro) * pdos, cudaMemcpyDeviceToHost);
	cudaFree(D_newname);
	cudaFree(D_pdos);
	cudaFree(D_proname);
}

void K_neiber()
{

}

void cypher(char* ch)
{
	int lag = 1;
	while (lag) {
		Que* Token = (Que*)malloc(100 * sizeof(Que));
		int high = 0;
		int i = 0, len = 0;
		while (i < strlen(ch))
		{
			int l = 0;
			while (ch[i] == ' ')
			{
				i++;
			}
			int p = 0;
			while (p < sizeof(Token[high].str))
			{
				Token[high].str[p] = '\0';
				p++;
			}
			while ((ch[i] != ' ') && (ch[i] != '\0'))
			{
				if (ch[i] == ':')
				{
					if (l == 1) {
						Token[high].tol = 0;
						high++;
						Token[high].str[0] = ch[i];
						Token[high].tol = 1;
						l = 0;
						i++;
						break;
					}
					else
					{
						Token[high].str[0] = ch[i];
						Token[high].tol = 1;
						l = 0;
						i++;
						break;
					}
				}
				if (ch[i] == ',')
				{
					if (l == 1) {
						Token[high].tol = 0;
						high++;
						Token[high].str[0] = ch[i];
						Token[high].tol = 2;
						l = 0;
						i++;
						break;
					}
					else
					{
						Token[high].str[0] = ch[i];
						Token[high].tol = 2;
						l = 0;
						i++;
						break;
					}
				}
				if (ch[i] == '[')
				{
					if (l == 1) {
						Token[high].tol = 0;
						high++;
						Token[high].str[0] = ch[i];
						Token[high].tol = 3;
						l = 0;
						i++;
						break;
					}
					else
					{
						Token[high].str[0] = ch[i];
						Token[high].tol = 3;
						l = 0;
						i++;
						break;
					}
				}
				if (ch[i] == ']')
				{
					if (l == 1) {
						Token[high].tol = 0;
						high++;
						Token[high].str[0] = ch[i];
						Token[high].tol = 4;
						l = 0;
						i++;
						break;
					}
					else
					{
						Token[high].str[0] = ch[i];
						Token[high].tol = 4;
						l = 0;
						i++;
						break;
					}
				}
				if (ch[i] == '(')
				{
					if (l == 1) {
						Token[high].tol = 0;
						high++;
						Token[high].str[0] = ch[i];
						Token[high].tol = 5;
						l = 0;
						i++;
						break;
					}
					else
					{
						Token[high].str[0] = ch[i];
						Token[high].tol = 5;
						l = 0;
						i++;
						break;
					}
				}
				if (ch[i] == ')')
				{
					if (l == 1) {
						Token[high].tol = 0;
						high++;
						Token[high].str[0] = ch[i];
						Token[high].tol = 6;
						l = 0;
						i++;
						break;
					}
					else
					{
						Token[high].str[0] = ch[i];
						Token[high].tol = 6;
						l = 0;
						i++;
						break;
					}
				}
				if (ch[i] == '-')
				{
					if (l == 1) {
						Token[high].tol = 0;
						high++;
						Token[high].str[0] = ch[i];
						Token[high].tol = 7;
						l = 0;
						i++;
						break;
					}
					else
					{
						Token[high].str[0] = ch[i];
						Token[high].tol = 7;
						l = 0;
						i++;
						break;
					}
				}
				if (ch[i] == '>')
				{
					if (l == 1) {
						Token[high].tol = 0;
						high++;
						Token[high].str[0] = ch[i];
						Token[high].tol = 8;
						l = 0;
						i++;
						break;
					}
					else
					{
						Token[high].str[0] = ch[i];
						Token[high].tol = 8;
						l = 0;
						i++;
						break;
					}
				}
				if (ch[i] == '=')
				{
					if (l == 1) {
						Token[high].tol = 0;
						high++;
						Token[high].str[0] = ch[i];
						Token[high].tol = 9;
						l = 0;
						i++;
						break;
					}
					else
					{
						Token[high].str[0] = ch[i];
						Token[high].tol = 9;
						l = 0;
						i++;
						break;
					}
				}
				Token[high].str[len] = ch[i];
				i++;
				len++;
				l = 1;
			}
			if (l == 1)
			{
				Token[high].tol = 0;
			}
			high++;
			len = 0;
		}
		char c1[] = "createnode";
		char c2[] = "createrel";
		char c3[] = "matchnode";
		char c4[] = "matchrel";
		char c5[] = "deletenode";
		char c6[] = "deleterel";
		char c7[] = "where";
		char c8[] = "and";
		char c9[] = "or";
		char c10[] = "change";
		char c11[] = "updatenode";
		char c12[] = "updaterel";
		char c13[] = "name";
		char c14[] = "labelname";
		char c15[] = "datainsert";
		char c17[] = "Test";
		char c18[] = "addproperty";
		char c19[] = "clear";
		char c20[] = "Exit";
		char c21[] = "deleteproperty";
		char c22[] = "renew";
		int z = 0;
		if (strcmp(Token[z].str, c1) == 0)    //createnode
		{
			char err[] = "[ input err ]";
			char nodename[20], labelname[20];
			z++;
			if (Token[z].tol == 5)           //(
			{
				z++;
				if (Token[z].tol == 0)    //str
				{
					strc1(nodename, Token[z].str);
					z++;
					if (Token[z].tol == 2)     //,
					{
						z++;
						if (Token[z].tol == 0)     //str
						{
							strc1(labelname, Token[z].str);
							z++;
							if (Token[z].tol == 6) {
								z++;
								if (z == high)
								{
									createNode(nodename, labelname);
									printf("create success!\n");
									printf("node:%d  relation:%d\n", num_n, num_r);
									break;
								}
							}
						}

					}

				}

			}

		}
		else if (strcmp(Token[z].str, c2) == 0) //createrel
		{
			char err[] = "[ input err! ]";
			char proname[20], A[20], B[20];
			z++;
			if (Token[z].tol == 5)     //(
			{
				z++;
				if (Token[z].tol == 0)     //str
				{
					strc1(A, Token[z].str);
					z++;
					if (Token[z].tol == 7)     //-
					{
						z++;
						if (Token[z].tol == 3)     //[
						{
							z++;
							if (Token[z].tol == 0)      //str
							{
								strc1(proname, Token[z].str);
								z++;
								if (Token[z].tol == 4)      //]
								{
									z++;
									if (Token[z].tol == 7)      //-
									{
										z++;
										if (Token[z].tol == 8)      //>
										{
											z++;
											if (Token[z].tol == 0)      //str
											{
												strc1(B, Token[z].str);
												z++;
												if (Token[z].tol == 6)      //)
												{
													z++;
													if (z == high) {
														//int lag=Create_pro(A, B, proname);
														createPro(A, B, proname);
														printf("create relation success!\n");
														printf("node:%d  relation:%d\n", num_n, num_r);
														break;
													}

												}

											}

										}

									}

								}

							}

						}

					}

				}

			}

		}
		else if (strcmp(Token[z].str, c3) == 0)//matchnode
		{
			char err[] = "[ input err! ]";
			z++;
			if (Token[z].tol == 0)      //str
			{
				char nodename[20];
				int  inode;
				strc1(nodename, Token[z].str);
				z++;
				if (Token[z].tol == 5)      //(
				{
					z++;
					if (strcmp(Token[z].str, c7) == 0)   //where
					{
						z++;
						if (strcmp(Token[z].str, c14) == 0)     //labelname
						{
							z++;
							if (Token[z].tol == 9)      //=
							{
								z++;
								if (Token[z].tol == 0)      //str
								{
									char labname1[20];
									strc1(labname1, Token[z].str);
									z++;
									if (Token[z].tol == 6)     //)
									{
										z++;
										if (z == high)
										{
											inode = Searchnode(nodename, labname1);
											printf("node:%d  relation:%d\n", num_n, num_r);
											printf("nodname:%s nodelabel:%s ");
											break;
										}

									}

								}

							}

						}

					}

				}

			}

		}
		else if (strcmp(Token[z].str, c4) == 0)  //match rel
		{
			int* irel = (int*)malloc(sizeof(int) * pdos);
			z++;
			if (Token[z].tol == 5)      //(
			{
				z++;
				if (Token[z].tol == 0)       //str
				{
					char A[20];
					strc1(A, Token[z].str);
					z++;
					if (Token[z].tol == 7)       //-
					{

						z++;
						if (Token[z].tol == 3)      //[
						{
							z++;
							if (Token[z].tol == 0)      //str
							{
								char proname[20];
								strc1(proname, Token[z].str);
								z++;
								if (Token[z].tol == 4)       //]
								{
									z++;
									if (Token[z].tol == 7)       //-
									{
										z++;
										if (Token[z].tol == 8)       //->
										{
											z++;
											if (Token[z].tol == 3)      //[
											{
												z++;
												if (Token[z].tol == 4)       //]
												{
													z++;
													if (Token[z].tol == 6)      //)
													{

														z++;
														if (z == high)
														{
															SearchPro_A(irel, proname, A);
															int i = 0;
															while (i != pdos)
															{
																if (irel[i] == 1)
																{

																	printf("%s-[%s]->%s", A, proname, headnode[headpro[i].l].name);
																}
																i++;
															}
															break;
														}
													}
												}
											}
											else if (Token[z].tol == 0)      //str
											{
												char B[20];
												strc1(B, Token[z].str);
												z++;
												if (Token[z].tol == 6)      //)
												{
													z++;
													if (z == high)
													{
														printf("222222");
														SearchPro_AB(irel, proname, A, B);
														int i = 0;
														while (i != pdos)
														{
															if (irel[i] == 1)
															{
																printf("%s-[%s]->%s", A, proname, B);

															}
															i++;
														}
														break;
													}
												}

											}

										}

									}

								}

							}

						}

					}

				}
				else if (Token[z].tol == 3)      //[
				{
					z++;
					if (Token[z].tol == 4)         //]
					{
						z++;
						if (Token[z].tol == 7)        //-
						{
							z++;
							if (Token[z].tol == 3)       //[
							{
								z++;
								if (Token[z].tol == 0)       //str
								{
									char proname[20];
									strc1(proname, Token[z].str);
									z++;
									if (Token[z].tol == 4)        //]
									{
										z++;
										if (Token[z].tol == 7)       //-
										{
											z++;
											if (Token[z].tol == 8)       //>
											{
												z++;
												if (Token[z].tol == 3)      //[
												{
													z++;
													if (Token[z].tol == 4)      //]
													{
														z++;
														if (Token[z].tol == 6)      //)
														{
															z++;
															if (z == high)
															{
																printf("333333333");
																SearchPro(irel, proname);
																int i = 0;
																while (i != pdos)
																{
																	if (irel[i] == 1)
																	{
																		printf("%s-[%s]->%s", headnode[headpro[i].h].name, proname, headnode[headpro[i].l].name);

																	}
																	i++;
																}
																break;
															}

														}

													}

												}
												else if (Token[z].tol == 0)    //str
												{
													char B[20];
													strc1(B, Token[z].str);
													z++;
													if (Token[z].tol == 6)     //)
													{
														z++;
														if (z == high)
														{
															printf("44444444444");
															SearchPro_B(irel, proname, B);
															int i = 0;
															if (irel[i] == 1)
															{
																printf("%s-[%s]->%s", headnode[headpro[i].h].name, proname, B);

															}
															i++;
															break;
														}

													}

												}

											}

										}

									}

								}

							}

						}

					}

				}

			}
			
		}
		else if (strcmp(Token[z].str, c6) == 0)  //delete rel
		{
			char err[] = "[ input err! ]";
			int* irel = (int*)malloc(sizeof(int) * pdos);
			z++;
			if (Token[z].tol == 5)      //(
			{
				z++;
				if (Token[z].tol == 0)       //str
				{
					char A[20];
					strc1(A, Token[z].str);
					z++;
					if (Token[z].tol == 7)       //-
					{
						z++;
						if (Token[z].tol == 3)      //[
						{
							z++;
							if (Token[z].tol == 0)      //str
							{
								char proname[20];
								strc1(proname, Token[z].str);
								z++;
								if (Token[z].tol == 4)       //]
								{
									z++;
									if (Token[z].tol == 7)       //-
									{
										z++;
										if (Token[z].tol == 8)       //->
										{
											z++;
											if (Token[z].tol == 3)      //[
											{
												z++;
												if (Token[z].tol == 4)       //]
												{
													z++;
													if (Token[z].tol == 6)      //)
													{

														z++;
														if (z == high)
														{
															DeletPro_A(irel, proname, A);
														}
														break;
													}
												}
											}
											else if (Token[z].tol == 0)      //str
											{
												char B[20];
												strc1(B, Token[z].str);
												z++;
												if (Token[z].tol == 6)      //)
												{
													z++;
													if (z == high)
													{
														DeletPro_AB(irel, proname, A, B);

													}
													break;

												}

											}

										}

									}

								}

							}

						}

					}

				}
				else if (Token[z].tol == 3)      //[
				{
					z++;
					if (Token[z].tol == 4)         //]
					{
						z++;
						if (Token[z].tol == 7)        //-
						{
							z++;
							if (Token[z].tol == 3)       //[
							{
								z++;
								if (Token[z].tol == 0)       //str
								{
									char proname[20];
									strc1(proname, Token[z].str);
									z++;
									if (Token[z].tol == 4)        //]
									{
										z++;
										if (Token[z].tol == 7)       //-
										{
											z++;
											if (Token[z].tol == 8)       //>
											{
												z++;
												if (Token[z].tol == 3)      //[
												{
													z++;
													if (Token[z].tol == 4)      //]
													{
														z++;
														if (Token[z].tol == 6)      //)
														{
															z++;
															if (z == high)
															{
																DeletPro(irel, proname);
															}
															break;
														}

													}

												}
												else if (Token[z].tol == 0)    //str
												{
													char B[20];
													strc1(B, Token[z].str);
													z++;
													if (Token[z].tol == 6)     //)
													{
														z++;
														if (z == high)
														{
															DeletPro_B(irel, proname, B);
														}
														break;
													}

												}

											}

										}

									}

								}

							}

						}

					}

				}

			}

		}
		else if (strcmp(Token[z].str, c5) == 0) //Deletenode
		{
			char err[] = "[ input err! ]";
			z++;
			if (Token[z].tol == 0)      //str
			{
				char nodename[20];
				strc1(nodename, Token[z].str);
				z++;
				if (Token[z].tol == 5)      //(
				{
					z++;
					if (strcmp(Token[z].str, c7) == 0)   //where
					{
						z++;
						if (strcmp(Token[z].str, c15) == 0)     //str
						{

							z++;
							if (Token[z].tol == 9)      //=
							{
								z++;
								if (Token[z].tol == 0)      //str
								{
									z++;
									char labname1[20];
									strc1(labname1, Token[z].str);
									if (Token[z].tol == 6)     //)
									{
										z++;
										if (z == high)
										{
											Deletnode(nodename, labname1);
											break;
										}

									}

								}

							}

						}

					}

				}

			}

		}
		else if (strcmp(Token[z].str, c11) == 0)// updatenode
		{
			char err[] = "[ input err! ]";
			z++;
			if (Token[z].tol == 0)      //str
			{
				char nodename[20];
				int  inode;
				strc1(nodename, Token[z].str);
				z++;
				if (Token[z].tol == 5)      //(
				{
					z++;
					if (strcmp(Token[z].str, c7) == 0)   //where
					{
						z++;
						if (strcmp(Token[z].str, c14) == 0)     //labname
						{
							z++;
							if (Token[z].tol == 9)      //=
							{
								z++;
								if (Token[z].tol == 0)      //str
								{
									char labname1[20];
									strc1(labname1, Token[z].str);
									z++;
									if (Token[z].tol == 6)     //)
									{
										z++;
										if (Token[z].tol == 1)
										{
											z++;
											if (strcmp(Token[z].str, c13) == 0)
											{
												z++;
												if (Token[z].tol == 9)
												{
													z++;
													if (Token[z].tol == 0)
													{
														char newname[20];
														z++;
														if (z == high)
														{
															updatenodename(nodename, newname);
														}

													}

												}


											}

										}

									}

								}

							}

						}

					}

				}

			}

		}
		else if (strcmp(Token[z].str, c12) == 0)  //update rel
		{
			char err[] = "[ input err! ]";
			//int* irel = (int*)malloc(sizeof(int) * pdos);
			z++;
			if (Token[z].tol == 5)      //(
			{
				z++;
				if (Token[z].tol == 0)       //str
				{
					char A[20];
					strc1(A, Token[z].str);
					z++;
					if (Token[z].tol == 7)       //-
					{
						z++;
						if (Token[z].tol == 3)      //[
						{
							z++;
							if (Token[z].tol == 0)      //str
							{
								char proname[20];
								strc1(proname, Token[z].str);
								z++;
								if (Token[z].tol == 4)       //]
								{
									z++;
									if (Token[z].tol == 7)       //-
									{
										z++;
										if (Token[z].tol == 8)       //->
										{
											z++;
											if (Token[z].tol == 3)      //[
											{
												z++;
												if (Token[z].tol == 4)       //]
												{
													z++;
													if (Token[z].tol == 6)      //)
													{

														z++;
														if (Token[z].tol == 1)
														{
															z++;
															if (Token[z].tol == 0)
															{
																char newname[20];
																strc1(newname, Token[z].str);
																if (z == high)
																{
																	updateProname_A(proname, A, newname);
																	printf("update success!");
																	break;
																}
															}
														}

													}
												}
											}
											else if (Token[z].tol == 0)      //str
											{
												char B[20];
												strc1(B, Token[z].str);
												z++;
												if (Token[z].tol == 6)      //)
												{
													z++;
													if (Token[z].tol == 1)
													{
														z++;
														if (Token[z].tol == 0)
														{
															char newname[20];
															strc1(newname, Token[z].str);
															if (z == high)
															{
																updateProname_AB(proname, A, B, newname);
																printf("update success!");
																break;
															}
														}
													}

												}

											}

										}

									}

								}

							}

						}

					}

				}
				else if (Token[z].tol == 3)      //[
				{
					z++;
					if (Token[z].tol == 4)         //]
					{
						z++;
						if (Token[z].tol == 7)        //-
						{
							z++;
							if (Token[z].tol == 3)       //[
							{
								z++;
								if (Token[z].tol == 0)       //str
								{
									char proname[20];
									strc1(proname, Token[z].str);
									z++;
									if (Token[z].tol == 4)        //]
									{
										z++;
										if (Token[z].tol == 7)       //-
										{
											z++;
											if (Token[z].tol == 8)       //>
											{
												z++;
												if (Token[z].tol == 3)      //[
												{
													z++;
													if (Token[z].tol == 4)      //]
													{
														z++;
														if (Token[z].tol == 6)      //)
														{
															z++;
															if (Token[z].tol == 1)
															{
																z++;
																if (Token[z].tol == 0)
																{
																	char newname[20];
																	strc1(newname, Token[z].str);
																	if (z == high)
																	{
																		updateProname(proname, newname);
																		printf("update success!");
																		break;
																	}
																}
															}

														}

													}

												}
												else if (Token[z].tol == 0)    //str
												{
													char B[20];
													strc1(B, Token[z].str);
													z++;
													if (Token[z].tol == 6)     //)
													{
														z++;
														if (Token[z].tol == 1)
														{
															z++;
															if (Token[z].tol == 0)
															{
																char newname[20];
																strc1(newname, Token[z].str);
																if (z == high)
																{
																	updateProname_B(proname, B, newname);
																	printf("update success!");
																	break;
																}
															}
														}

													}

												}

											}

										}

									}

								}

							}

						}

					}

				}

			}

		}
		else if (strcmp(Token[z].str, c22) == 0)
		{
			renew();
		}
		else if (strcmp(Token[z].str, c20) == 0)
		{
			ex = 0;
			printf("exit success!");
			break;
		}
		else if (strcmp(Token[z].str, c15) == 0)
		{
			//char  filename[] = "C:\\Users\\YuWenJian\\Desktop\\task+++";
			///Datainsert(filename);
			//char re[] = "insert finish!";
			//return re;
		}
		else
		{
			break;
		}
	}
}

int main()
{  
	while (ex) 
	{
		char input_cypher[100];
		printf("input cypher:");
		gets(input_cypher);
		cypher(input_cypher);
	}
	
	return 0;
}